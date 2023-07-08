extends Node2D

const SPEED: int = 100

var max_health: int = 1600
var health: int = 1600 #34000
var activate_shield = false
var rotate: bool = true
var reward: Dictionary = {
	exp = 100,
	gold = 100
}

var attack: int = 3
var defense: int = 0
var spareable: bool = true

@onready var enemy_name: String = [
	"Yi Fan",
	"奕凡",
	"奕凡",
	"Yi Fen",
	"エキファン"
][db.data.settings.language]
@onready var sprite: Sprite2D = $Sprite2D
@onready var shield: Sprite2D = sprite.get_node("Shield")
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

func _ready() -> void:
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
		sprite.rotation_degrees += PI * delta * SPEED
		shield.rotation_degrees += PI * delta * (-SPEED * 1.5)
	if sprite.rotation_degrees >= 360:
		sprite.rotation_degrees -= 360

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

func shake(times: int = 15, default_delay_time: float = 0.01, target: Node2D = get_child(0), fixed_delay_time: bool = false) -> void:
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

enum INVERTED_DIRECTION {
	DOWN,
	LEFT,
	UP,
	RIGHT
}
const attacks_path: String = "res://Instances/Attacks/"
const TOTAL_SPEAR_IN_A_ROUND: int = 50
const SPEAR_ATTACK_GAP_TIME: float = 0.25
const TOTAL_YELLOW_SPEAR_IN_A_ROUND: int = 20
const YELLOW_SPEAR_ATTACK_GAP_TIME: float = 0.4
var attacks: Array[String] = os.listdir(attacks_path)

func cast_attack() -> void:
	battlefield.set_property(Vector2(96, 96), Vector2(528, 272), true)
	player.respawn()
	player.change_form(player.SOUL.YELLOW)

func cast_attack_unused() -> void:
	player.shield_angle = 0
	player_shield.rotation_degrees = 0
	battlefield.set_property(Vector2(96, 96), Vector2(528, 272), true)
	
	await time.sleep(battlefield.transition_time)
	
	player.respawn()
	create_tween().tween_property(self, "modulate:a", 0.5, 0.5) 
	player.change_form(player.SOUL.GREEN)
	
	await time.sleep(1.0)
	
	for spear_index in range(TOTAL_SPEAR_IN_A_ROUND):
		var spear: Area2D = load("res://Instances/spear.tscn").instantiate()
		var random_spear_spawnpoint_index: int = randi_range(0, spear_spawnpoints.get_child_count() - 1)
		
		spear.direction = random_spear_spawnpoint_index
		spear_spawner.add_child(spear)
		spear.global_position = spear_spawnpoints.get_child(spear.direction).global_position
		
		if spear_index == 0:
			spear_spawner.locate_red_spear()
		
		await time.sleep(SPEAR_ATTACK_GAP_TIME)
	
	await time.sleep(5.0)
	
	State.set_state(State.MAIN_STATE.TAKING_ACTION)
	player_green.hide()
	create_tween().tween_property(self, "modulate:a", 1, 0.5)
	actions.take_action(true)

"""
#Yellow spears attack.
func cast_attack() -> void:
	#battlefield.set_property(Vector2(272, 192), Vector2(440, 336), true)
	#battlefield.set_property(Vector2(96, 96), Vector2(528, 384), true)
	battlefield.set_property(Vector2(96, 96), Vector2(528, 272), true)
	
	await time.sleep(battlefield.transition_time)
	
	player.respawn()
	create_tween().tween_property(self, "modulate:a", 0.5, 0.5) 
	player.change_form(player.SOUL.GREEN)
	
	await time.sleep(1.0)
	
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
	
	State.set_state(State.MAIN_STATE.TAKING_ACTION)
	player_green.hide()
	player.shield_angle = 0
	player_green.get_node("Shield").rotation_degrees = 0
	create_tween().tween_property(self, "modulate:a", 1, 0.5)
	actions.take_action(true)
"""

"""
#Normal spears attack.
func cast_attack() -> void:
	create_tween().tween_property(self, "modulate:a", 0.5, 0.5) 
	player.change_form(player.SOUL.GREEN)
	
	await time.sleep(1.0)
	
	for spear_index in range(TOTAL_SPEAR_IN_A_ROUND):
		var spear: Area2D = load("res://Instances/spear.tscn").instantiate()
		var random_spear_spawnpoint_index: int = randi_range(0, spear_spawnpoints.get_child_count() - 1)
		
		spear.direction = random_spear_spawnpoint_index
		spear_spawner.add_child(spear)
		spear.global_position = spear_spawnpoints.get_child(spear.direction).global_position
		
		if spear_index == 0:
			spear_spawner.locate_red_spear()
		
		await time.sleep(SPEAR_ATTACK_GAP_TIME)
	
	await time.sleep(5.0)
	
	State.set_state(State.MAIN_STATE.TAKING_ACTION)
	player_green.hide()
	player.shield_angle = 0
	player_green.get_node("Shield").rotation_degrees = 0
	create_tween().tween_property(self, "modulate:a", 1, 0.5)
	actions.take_action(true)
"""

"""
#bones attack
func cast_attack() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	var attack_move: Node2D = load(attacks_path + random.choice(attacks)).instantiate()
	var attack_animation: AnimationPlayer = attack_move.get_child(attack_move.get_child_count() - 1)
	var actions: Node2D = get_tree().get_first_node_in_group("actions")
	
	player.change_form(player.SOUL.RED)
	
	await time.sleep(1)
	
	battlefield.add_child(attack_move)
	
	await time.sleep(attack_animation.get_current_animation_length())
	
	attack_move.queue_free()
	
	State.set_state(State.MAIN_STATE.TAKING_ACTION)
	
	actions.take_action(true)
"""

"""
@onready var villian_sprite: Sprite2D = get_child(0)
@onready var origin_x: float = villian_sprite.position.x

func shake(times: int = 15, default_delay_time: float = 0.01, fixed_delay_time: bool = false):
	var offset_sign: bool = false
	var delay_time: float = default_delay_time
	var shake_range: Array = range(times, 0, -1)
	
	for shake_index in shake_range:
		villian_sprite.position.x = origin_x + (shake_index * ((int(offset_sign) * 2) - 1)) #[-1, 1][int(offset_sign)]
		offset_sign = not offset_sign
		if not fixed_delay_time:
			delay_time = default_delay_time * shake_range[shake_index - 1]
		await time.sleep(delay_time)
	villian_sprite.position.x = origin_x
"""
