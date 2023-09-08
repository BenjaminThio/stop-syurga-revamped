extends Node2D

var rotate: bool = true
var activate_shield = false

@export var rotate_speed: int = 100
@export var max_health: int = 28900
@export var health: int = max_health
@export var attack: int = 3
@export var defense: int = 0
@export var spareable: bool = false
@export var reward: Dictionary = {
	exp = 100,
	gold = 100
}

@onready var enemy_name: String = [
	"Yi Fan",
	"奕凡",
	"奕凡",
	"Yi Fen",
	"エキファン"
][db.data.settings.language]
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield: Sprite2D = animated_sprite.get_node("Shield")
@onready var health_bar: ProgressBar = $HealthBar
@onready var speech: Node2D = get_tree().get_first_node_in_group("speech")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var player_green: Node2D = player.get_node("Green")
@onready var player_shield: Node2D = player_green.get_node("Shield")
@onready var spear_spawnpoints: Node2D = player.get_node("SpearAttack/Spawnpoints")
@onready var spear_spawner: Node2D = player.get_node("SpearAttack/Spawner")
@onready var actions: Node2D = get_tree().get_first_node_in_group("actions")
@onready var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
@onready var main: Node2D = get_tree().get_root().get_node("Main")
@onready var webs: Node2D = get_tree().get_first_node_in_group("webs")

enum SPEAR_DIRECTION {
	UP,
	RIGHT,
	DOWN,
	LEFT
}
enum INVERTED_DIRECTION {
	DOWN,
	LEFT,
	UP,
	RIGHT
}
enum WEB_DIRECTION {
	LEFT,
	RIGHT
}
enum ATTACK {
	SPIDER
}
enum SPIDER_DIRECTION {
	LEFT,
	RIGHT
}
enum SPEAR_TYPE {
	RED,
	YELLOW
}
const attacks_path: String = "res://Instances/Attacks/"
const TOTAL_SPEAR_IN_A_ROUND: int = 50
const SPEAR_ATTACK_GAP_TIME: float = 0.25
const TOTAL_YELLOW_SPEAR_IN_A_ROUND: int = 20
const YELLOW_SPEAR_ATTACK_GAP_TIME: float = 0.4
const PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE: int = 200
const TOTAL_SPIDER_IN_A_ROUND: int = 50
var attacks: Array[String] = os.listdir(attacks_path)
var attack_index = 0
var spider_scene: PackedScene = preload("res://Instances/spider.tscn")
var hand_scene: PackedScene = preload("res://Instances/hand.tscn")
var white_spear_scene: PackedScene = preload("res://Instances/white_spear.tscn")
var rising_spear_scene: PackedScene = preload("res://Instances/rising_white_spear.tscn")
var swirl_scene: PackedScene = preload("res://Instances/swirl.tscn")

func _ready() -> void:
	#Reset state engine.
	State.current_state = State.MAIN_STATE.IDLE
	State.substates_queue.clear()
	State.is_substate_busy = false
	
	if Global.loop_attack_index != null:
		attack_index = Global.loop_attack_index
	
	health_bar.max_value = max_health
	update_health_bar(false)
	
	set_rotate(false)
	await time.sleep(1.0)
	speech.set_contents([
		[
			"You're gonna to try a little harder than THAT!",
			"看来你需要加把劲才行！",
			"瞻以尔需努力更甚！",
			"Nampaknya kamu perlu lebih berusaha daripada ITU!",
			"それじゃあもっと頑張らないと！"
		][db.data.settings.language]
	])
	speech.upcoming_event = (
		func() -> void:
			State.set_state(State.MAIN_STATE.TAKING_ACTION)
			actions.take_action()
			main.play_background_music()
	)

func _process(delta) -> void:
	if rotate:
		animated_sprite.rotation_degrees += PI * delta * rotate_speed
		shield.rotation_degrees += PI * delta * (-rotate_speed * 1.5)
	if animated_sprite.rotation_degrees >= 360:
		animated_sprite.rotation_degrees -= 360

func set_rotate(boolean: bool) -> void:
	rotate = boolean

func deal_damage(damage_value: int) -> void:
	if damage_value < 0:
		Debug.log_error("The negative damage value is not acceptable.", true)
		return
	
	if health - damage_value >= 0:
		health -= int(damage_value)
	else:
		health = 0
	Audio.play_sound("hurtfen")
	
	update_health_bar()

func update_health_bar(require_tween: bool = true) -> void:
	if (require_tween):
		await create_tween().tween_property(health_bar, "value", health, 0.7).finished
	else:
		health_bar.value = health

var id: int = 0
var shield_activate_time: float = 0.5
@export var passive_skill_duration: float = 2.0

func _on_villian_shield_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		id += 1
		var local_id: int = id
		
		Audio.play_sound("shield_activated")
		area.queue_free()
		create_tween().tween_property(shield, "self_modulate:a", 1, shield_activate_time)
		await time.sleep(passive_skill_duration)
		
		if local_id != id:
			return
		
		var shield_deactivation_blink_times: int = 20
		var weaken_shield: bool = false
		var blink_counter: int = 0
		var blink_transition_duration: float = shield_activate_time
		var blink_transition_duration_reduction: float = blink_transition_duration * 0.2 # 20% from blink_transition_duration
		var min_blink_transition_duration: float = blink_transition_duration * 0.4 # 40% from blink_transition_duration
		
		for _i in range(shield_deactivation_blink_times):
			var tween: Tween = create_tween()
			if weaken_shield:
				tween.tween_property(shield, "self_modulate:a", 0, blink_transition_duration)
			else:
				tween.tween_property(shield, "self_modulate:a", 1, blink_transition_duration)
			blink_counter += 1
			if blink_counter % 2 == 0 and blink_transition_duration - blink_transition_duration_reduction > min_blink_transition_duration:
				blink_transition_duration -= blink_transition_duration_reduction
			weaken_shield = not weaken_shield
			await time.sleep(blink_transition_duration)
			if local_id != id:
				return

func shake(times: int = 15, default_delay_time: float = 0.01, target: Node2D = get_node("AnimatedSprite2D"), fixed_delay_time: bool = false) -> void:
	var offset_sign: bool = false
	var delay_time: float = default_delay_time
	var shake_range: Array = range(times, 0, -1)
	
	for shake_index in shake_range:
		target.position.x = shake_index * ((int(offset_sign) * 2) - 1) #[-1, 1][int(offset_sign)]
		offset_sign = not offset_sign
		if not fixed_delay_time:
			delay_time = default_delay_time * shake_range[shake_index - 1]
		await time.sleep(delay_time)
	target.position.x = 0

func cast_attack():
	actions.reset()
	
	if typeof(attack_index) != TYPE_INT and typeof(attack_index) != TYPE_NIL:
		var error: String = "The value of the variable, `attack_index` should be in `TYPE_INT` or `TYPE_NIL`."
		
		actions.description = "Error: " + error
		Debug.log_error(error)
		State.set_state(State.MAIN_STATE.TAKING_ACTION)
		actions.take_action()
		player.show()
		return
	
	create_tween().tween_property(self, "modulate:a", 0.5, 0.5)
	player.shield_angle = 0
	player_shield.rotation_degrees = 0
	
	if typeof(attack_index) == TYPE_INT:
		if attack_index == 0:
			battlefield.set_property(Vector2(272, 192), Vector2(440, 336), true)
		elif attack_index >= 1 and attack_index <= 2 or attack_index >= 14 and attack_index <= 16:
			await battlefield.set_property(Vector2(96, 96), Vector2(528, 272), true)
		elif attack_index >= 3 and attack_index <= 4:
			await battlefield.set_property(Vector2(272, 278), Vector2(440, 240), true)
		elif attack_index == 5:
			await battlefield.set_property(Vector2(272, 192), Vector2(440, 336), true)
		elif attack_index == 6 or attack_index == 17:
			await battlefield.set_property(Vector2(224, 192), Vector2(464, 336), true)
		elif attack_index == 7:
			await battlefield.set_property(Vector2(144, 192), Vector2(504, 336), true)
		elif attack_index == 8:
			await battlefield.set_property(Vector2(80, 192), Vector2(536, 336), true)
		elif attack_index >= 9 and attack_index <= 10:
			await battlefield.set_property(Vector2(272, 192), Vector2(440, 336), true)
		elif attack_index == 11:
			await battlefield.set_property(Vector2(384, 192), Vector2(384, 336), true)
		elif attack_index == 12:
			await battlefield.set_property(Vector2(288, 288), Vector2(432, 240), true)
		elif attack_index == 13:
			await battlefield.set_property(Vector2(256, 272), Vector2(448, 256), true)
		elif attack_index == 18:
			await battlefield.set_property(Vector2(86, 105), Vector2(533, 424), true)
		elif attack_index == 19:
			await battlefield.set_property(Vector2(768, 337), Vector2(192, 192), true)
	elif typeof(attack_index) == TYPE_NIL:
		await battlefield.set_property(Vector2(272, 192), Vector2(440, 336), true)
	
	player.respawn()
	player.web_index = 1
	
	if typeof(attack_index) == TYPE_INT:
		if attack_index == 0 or attack_index == 11:
			var attack_scene_name: String = ""
			
			match attack_index:
				0:
					attack_scene_name = "attack_1"
				11:
					attack_scene_name = "attack_3"
			
			var attack_move: Node2D = load(attacks_path + attack_scene_name + ".tscn").instantiate()
			var attack_animation: AnimationPlayer = attack_move.get_child(-1)
			
			player.change_form(player.SOUL.INTEGRITY)
			
			await time.sleep(1)
			
			battlefield.add_child(attack_move)
			
			await time.sleep(attack_animation.get_current_animation_length())
			
			attack_move.queue_free()
		elif attack_index >= 1 and attack_index <= 2 or attack_index == 14:
			player.change_form(player.SOUL.KINDNESS)
			
			await time.sleep(1.0)
			
			if attack_index == 1 or attack_index == 14:
				for spear_index in range(TOTAL_SPEAR_IN_A_ROUND):
					var spear: Area2D = load("res://Instances/spear.tscn").instantiate()
					var random_spear_spawnpoint_index: int = randi_range(0, spear_spawnpoints.get_child_count() - 1)
					
					spear.direction = random_spear_spawnpoint_index
					spear_spawner.add_child(spear)
					spear.global_position = spear_spawnpoints.get_child(spear.direction).global_position
					
					if spear_index == 0:
						spear_spawner.locate_red_spear()
					
					await time.sleep(SPEAR_ATTACK_GAP_TIME)
			
			if attack_index == 14:
				await time.sleep(0.5)
			
			if attack_index == 2 or attack_index == 14:
				for _i in range(TOTAL_YELLOW_SPEAR_IN_A_ROUND):
					var yellow_spear_origin: Node2D = load("res://Instances/yellow_spear.tscn").instantiate()
					var yellow_spear: Area2D = yellow_spear_origin.get_node("YellowSpear")
					var random_spear_spawnpoint_index: int = randi_range(0, spear_spawnpoints.get_child_count() - 1)
					var inverted_direction: String
					
					yellow_spear.direction = random_spear_spawnpoint_index
					inverted_direction = INVERTED_DIRECTION.find_key(yellow_spear.direction).capitalize()
					spear_spawner.add_child(yellow_spear_origin)
					yellow_spear.global_position = player.global_position
					yellow_spear.global_position = spear_spawnpoints.get_node(inverted_direction).global_position
					yellow_spear.monitorable = true
					yellow_spear.monitoring = true
					
					await time.sleep(YELLOW_SPEAR_ATTACK_GAP_TIME)
			
			await time.sleep(5.0)
		elif attack_index == 3:
			var attack_move: Node2D = load(attacks_path + "attack_2.tscn").instantiate()
			var attack_animation: AnimationPlayer = attack_move.get_child(-1)
			
			player.change_form(player.SOUL.JUSTICE)
			
			await time.sleep(1)
			
			main.add_child(attack_move)
			
			await time.sleep(attack_animation.get_current_animation_length())
			
			attack_move.queue_free()
		elif attack_index == 4:
			var attack_move: Node2D = load(attacks_path + "attack_2.tscn").instantiate()
			var attack_animation: AnimationPlayer = attack_move.get_child(-1)
			var recorder_sign: AnimatedSprite2D = battlefield.get_node("RecorderSign")
			
			player.change_form(player.SOUL.JUSTICE)
			
			await time.sleep(1)
			
			main.add_child(attack_move)
			battlefield.sign_activated = true
			recorder_sign.frame = 0
			
			await time.sleep(attack_animation.get_current_animation_length())
			
			attack_animation.stop()
			recorder_sign.frame = 1
			attack_animation.play_backwards("attack2")
			
			await time.sleep(attack_animation.get_current_animation_length())
			
			battlefield.sign_activated = false
			attack_move.queue_free()
		elif attack_index == 5:
			player.change_form(player.SOUL.PERSEVERANCE)
			
			for spider_index in range(TOTAL_SPIDER_IN_A_ROUND):
				#var random_webs: Array = random.sample(webs.get_children(), 2)
				
				#for random_web in random_webs:
					var spider: Area2D = spider_scene.instantiate()
					var random_web: ColorRect = random.choice(webs.get_children())
					@warning_ignore("int_as_enum_without_cast")
					var random_direction: WEB_DIRECTION = randi_range(0, WEB_DIRECTION.size() - 1)
					var random_speed: int = randi_range(200, 250)
					
					main.add_child(spider)
					spider.direction = random_direction
					spider.speed = random_speed
					if random_direction == WEB_DIRECTION.LEFT:
						spider.global_position = Vector2(random_web.global_position.x + random_web.size.x + PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE, random_web.global_position.y + random_web.pivot_offset.y)
					elif random_direction == WEB_DIRECTION.RIGHT:
						spider.global_position = Vector2(random_web.global_position.x - PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE, random_web.global_position.y + random_web.pivot_offset.y)
					await time.sleep(0.4)
			
			await time.sleep(5.0)
		elif attack_index == 6 or attack_index == 17:
			var disco_ball: Area2D = load("res://Instances/disco_ball.tscn").instantiate()
			
			player.change_form(player.SOUL.JUSTICE)
			
			if attack_index == 6:
				disco_ball.light_spawnpoint_rotate_speed = 300
				disco_ball.difficulty = 1
			elif attack_index == 17:
				disco_ball.light_spawnpoint_rotate_speed = 200
				disco_ball.difficulty = 2
			
			player.global_position.y += 50
			battlefield.add_child(disco_ball)
			disco_ball.global_position = Vector2(576, 368)
			
			await time.sleep(20.0)
			
			disco_ball.queue_free()
		elif attack_index == 7:
			var falling_attack: VBoxContainer = load("res://Instances/Attacks/falling_attack.tscn").instantiate()
			
			player.change_form(player.SOUL.JUSTICE)
			main.add_child(falling_attack)
			
			await time.sleep(falling_attack.transition_duration + falling_attack.rewind_duration)
		elif attack_index == 8:
			var falling_attack: VBoxContainer = load("res://Instances/Attacks/falling_attack.tscn").instantiate()
			
			player.change_form(player.SOUL.JUSTICE)
			falling_attack.transition_type = Tween.TRANS_LINEAR
			falling_attack.transition_duration = 24.0
			falling_attack.rows_count = 15
			falling_attack.row_space = 300
			falling_attack.attacks_count_in_a_row = 2
			falling_attack.rewindable = false
			falling_attack.attacks = [falling_attack.bomb, falling_attack.barrier] as Array[PackedScene]
			falling_attack.repeated_random_attack = false
			main.add_child(falling_attack)
			
			await time.sleep(falling_attack.transition_duration)
		elif attack_index == 9:
			player.change_form(player.SOUL.PERSEVERANCE)
			
			for croissant_index in range(20):
				#var random_webs: Array = random.sample(webs.get_children(), 2)
				
				#for random_web in random_webs:
					var croissant: Area2D = load("res://Instances/croissant.tscn").instantiate()
					var random_web: ColorRect = random.choice(webs.get_children())
					@warning_ignore("int_as_enum_without_cast")
					var random_direction: WEB_DIRECTION = randi_range(0, WEB_DIRECTION.size() - 1)
					
					main.add_child(croissant)
					croissant.direction = random_direction
					if random_direction == WEB_DIRECTION.LEFT:
						croissant.global_position = Vector2(random_web.global_position.x + random_web.size.x + 300, random_web.global_position.y + random_web.pivot_offset.y)
					elif random_direction == WEB_DIRECTION.RIGHT:
						croissant.global_position = Vector2(random_web.global_position.x - 300, random_web.global_position.y + random_web.pivot_offset.y)
					await time.sleep(1.0)
			
			await time.sleep(5.0)
		elif attack_index == 10:
			var attack_pattern: Array = []
		
			for _i in range(30):
				attack_pattern.append(new_spider(SPIDER_DIRECTION.LEFT, 370, 1))
				attack_pattern.append(new_spider(SPIDER_DIRECTION.LEFT, 180, 0, 0.7))
				attack_pattern.append(new_spider(SPIDER_DIRECTION.RIGHT, 200, 2))
			
			for _i in range(8):
				attack_pattern.append(new_spider(SPIDER_DIRECTION.LEFT, 400, 1, 0.1))
				
			player.change_form(player.SOUL.PERSEVERANCE)
			
			for attack_config in attack_pattern:
				var delay_duration: float = attack_config[-1]
				var spider: Area2D = spider_scene.instantiate()
				var direction: SPIDER_DIRECTION = attack_config[0]
				var speed: int = attack_config[1]
				var web: ColorRect = webs.get_child(attack_config[2])
				
				spider.direction = direction
				spider.speed = speed
				
				if direction == SPIDER_DIRECTION.LEFT:
					spider.global_position = Vector2(web.global_position.x + web.size.x + PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE, web.global_position.y + web.pivot_offset.y)
				elif direction == SPIDER_DIRECTION.RIGHT:
					spider.global_position = Vector2(web.global_position.x - PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE, web.global_position.y + web.pivot_offset.y)
					
				main.add_child(spider)
				
				await time.sleep(delay_duration)
			
			await time.sleep(5.0)
		elif attack_index == 12:
			player.change_form(player.SOUL.DETERMINATION)
			
			for _i in range(20):
				var hand: Sprite2D = hand_scene.instantiate()
				
				main.add_child(hand)
				hand.direction = randi_range(0, 3)
				if hand.direction in [hand.DIRECTION.RIGHT, hand.DIRECTION.LEFT]:
					hand.move_distance = battlefield.size.x - 30
				elif hand.direction in [hand.DIRECTION.DOWN, hand.DIRECTION.UP]:
					hand.move_distance = battlefield.size.y - 30
				
				if hand.direction == hand.DIRECTION.RIGHT:
					hand.global_position = Vector2(battlefield.global_position.x + 30, battlefield.global_position.y + 30)
				elif hand.direction == hand.DIRECTION.DOWN:
					hand.global_position = Vector2(battlefield.global_position.x + battlefield.size.x - 30, battlefield.global_position.y + 30)
				elif hand.direction == hand.DIRECTION.LEFT:
					hand.global_position = Vector2(battlefield.global_position.x + battlefield.size.x - 30, battlefield.global_position.y + battlefield.size.y - 30)
				elif hand.direction == hand.DIRECTION.UP:
					hand.global_position = Vector2(battlefield.global_position.x + 30, battlefield.global_position.y + battlefield.size.y - 30)
				
				await time.sleep(1.0)
			
			await time.sleep(1.0)
		elif attack_index == 13:
			var white_spear_spawnpoints: Array[Node] = get_tree().get_first_node_in_group("white_spear_spawnpoints").get_children()
			
			for _i in range(50):
				var white_spear: Area2D = white_spear_scene.instantiate()
				
				main.add_child(white_spear)
				white_spear.global_position = random.choice(white_spear_spawnpoints).global_position
				
				await time.sleep(0.3)
			
			await time.sleep(3.0)
		elif attack_index >= 15 and attack_index <= 16:
			var attack_pattern: Array = []
			
			player.change_form(player.SOUL.KINDNESS)
			
			if attack_index == 15:
				for _i in range(2):
					attack_pattern.append_array([
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.08),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 500, 0.3),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 650, 0.06),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 500, 0.5)
					])
				
				for _i in range(2):
					attack_pattern.append_array([
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.06),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 500, 0.3),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 650, 0.06),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 500, 0.5)
					])
				
				for _i in range(2):
					attack_pattern.append_array([
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.08),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 500, 0.3),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 650, 0.08),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 500, 0.5)
					])
				
				for _i in range(2):
					attack_pattern.append_array([
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.08),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 500, 0.3),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.1),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 650, 0.08),
						new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 500, 0.5)
					])
				
				attack_pattern.append_array([
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.DOWN, 800, 0.4),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.RIGHT, 800, 0.4),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.LEFT, 800, 0.4),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.UP, 800, 0.4)
				])
				
				attack_pattern.append(new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 100, 0.3))
			
			elif attack_index == 16:
				attack_pattern.append_array([
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 170, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 170, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 170, 1.8),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 700, 0.4),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 700, 0.7),
					
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.RIGHT, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.UP, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.LEFT, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.DOWN, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.LEFT, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.UP, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.DOWN, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.LEFT, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.RIGHT, 650, 0.65),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 400, 0.2),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.UP, 650, 1.0),
					
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 300, 0.3),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 300, 0.3),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 300, 0.3),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 300, 0.3),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.RIGHT, 300, 0.3),
					new_spear(SPEAR_TYPE.RED, SPEAR_DIRECTION.DOWN, 300, 0.5),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.LEFT, 550, 0.3),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.UP, 550, 0.3),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.LEFT, 550, 0.3),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.UP, 550, 0.3),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.LEFT, 550, 0.3),
					new_spear(SPEAR_TYPE.YELLOW, SPEAR_DIRECTION.UP, 550, 0.3),
				])
			
			for attack_config_index in range(attack_pattern.size()):
				var spear_type: SPEAR_TYPE = attack_pattern[attack_config_index][0]
				var spear_direction: SPEAR_DIRECTION = attack_pattern[attack_config_index][1]
				var spear_speed: int = attack_pattern[attack_config_index][2]
				var delay_duration: float = attack_pattern[attack_config_index][-1]
				
				if spear_type == SPEAR_TYPE.RED:
					var spear: Area2D = load("res://Instances/spear.tscn").instantiate()
					
					spear.direction = spear_direction
					spear.speed = spear_speed
					spear_spawner.add_child(spear)
					spear.global_position = spear_spawnpoints.get_child(spear.direction).global_position
					
					#if attack_config_index == 0:
					spear_spawner.locate_red_spear()
				elif spear_type == SPEAR_TYPE.YELLOW:
					var yellow_spear_origin: Node2D = load("res://Instances/yellow_spear.tscn").instantiate()
					var yellow_spear: Area2D = yellow_spear_origin.get_node("YellowSpear")
					var inverted_direction: String
					
					yellow_spear.direction = spear_direction
					yellow_spear.speed = spear_speed
					inverted_direction = INVERTED_DIRECTION.find_key(yellow_spear.direction).capitalize()
					spear_spawner.add_child(yellow_spear_origin)
					yellow_spear.global_position = player.global_position
					yellow_spear.global_position = spear_spawnpoints.get_node(inverted_direction).global_position
					yellow_spear.monitorable = true
					yellow_spear.monitoring = true
				
				await time.sleep(delay_duration)
			
			await time.sleep(3.0)
		elif attack_index == 18:
			var rising_spear_spawnpoints: Array[Node] = get_tree().get_first_node_in_group("rising_spear_spawnpoints").get_children()
			
			player.change_form(player.SOUL.DETERMINATION)
			
			for _i in range(30):
				var random_spawnpoint: Marker2D = random.choice(rising_spear_spawnpoints)
				var rising_spear: Area2D = rising_spear_scene.instantiate()
				
				random_spawnpoint.add_child(rising_spear)
				
				await time.sleep(0.5)
			
			await time.sleep(1.4)
		elif attack_index == 19:
			for _i in range(15):
				var swirl: Marker2D = swirl_scene.instantiate()
				
				main.add_child(swirl)
				swirl.global_position = player.global_position
				
				await time.sleep(1.5)
			
			await time.sleep(2.0)
		if player_green.visible:
			player_green.hide()
		if webs.visible:
			webs.hide()
		create_tween().tween_property(self, "modulate:a", 1, 0.5)
		State.set_state(State.MAIN_STATE.TAKING_ACTION)
		if player.perseverance_soul_tween != null:
			player.perseverance_soul_tween.kill()
			player.perseverance_soul_tween = null
		actions.take_action(true)
		if Global.loop_attack_index == null:
			if attack_index < 19:
				attack_index += 1
			else:
				attack_index = 0
	elif typeof(attack_index) == TYPE_NIL:
		var attack_pattern: Array = []
		
		for _i in range(30):
			attack_pattern.append(new_spider(SPIDER_DIRECTION.LEFT, 370, 1))
			attack_pattern.append(new_spider(SPIDER_DIRECTION.LEFT, 180, 0, 0.7))
			attack_pattern.append(new_spider(SPIDER_DIRECTION.RIGHT, 200, 2))
		
		for _i in range(8):
			attack_pattern.append(new_spider(SPIDER_DIRECTION.LEFT, 400, 1, 0.1))
			
		player.change_form(player.SOUL.PERSEVERANCE)
		
		for attack_config in attack_pattern:
			var attack_type: ATTACK = attack_config[0]
			var delay_duration: float = attack_config[-1]
			
			if attack_type == ATTACK.SPIDER:
				var spider: Area2D = spider_scene.instantiate()
				var direction: SPIDER_DIRECTION = attack_config[1]
				var speed: int = attack_config[2]
				var web: ColorRect = webs.get_child(attack_config[3])
				
				spider.direction = direction
				spider.speed = speed
				
				if direction == SPIDER_DIRECTION.LEFT:
					spider.global_position = Vector2(web.global_position.x + web.size.x + PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE, web.global_position.y + web.pivot_offset.y)
				elif direction == SPIDER_DIRECTION.RIGHT:
					spider.global_position = Vector2(web.global_position.x - PERSEVERANCE_ATTACK_SPAWNPOINT_DISTANCE, web.global_position.y + web.pivot_offset.y)
					
				main.add_child(spider)
			
			await time.sleep(delay_duration)
		
		await time.sleep(5.0)

func new_spider(direction: SPIDER_DIRECTION, speed: int, web_index: int, delay_duration: float = 0):
	return [direction, speed, web_index, delay_duration]

func new_spear(type: SPEAR_TYPE, direction: SPEAR_DIRECTION, speed: int, delay_duration: float = 0):
	return [type, direction, speed, delay_duration]
