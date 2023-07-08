extends Node2D

enum DIRECTION {
	LEFT,
	RIGHT
}

const PAUSE_TIME: float = 1.7

var speed: float = randi_range(470, 500)
var distance: float = 0
var transition_time: float = 0
var front_meter_range: float = 50
var back_meter_range: float = 50
var max_damage: float = 1700
var min_damage: float = max_damage * 0.1
var has_damaged: bool = false
var missed: bool = false

var direction: DIRECTION = random.choice(DIRECTION.values())
var tween: Tween = null
var starting_point: Marker2D
var end_point: Marker2D

var weapon_scene: PackedScene = preload("res://Instances/weapon.tscn")
var hurt_value_pop_up_animation_scene: PackedScene = preload("res://Instances/hurt_value.tscn")

@onready var slider: AnimatedSprite2D = $Slider
@onready var point1: Marker2D = $Background/Point1
@onready var point2: Marker2D = $Background/Point2
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer
@onready var main: Node2D = get_tree().get_root().get_node("Main")
@onready var villian: Node2D = get_tree().get_first_node_in_group("villian")
@onready var villian_sprite: Node2D = villian.get_child(0)
@onready var villian_health_bar: ProgressBar = villian.get_child(1)
@onready var actions: Node2D = get_tree().get_first_node_in_group("actions")
@onready var speech: Node2D = get_tree().get_first_node_in_group("speech")
@onready var background_music_player: AudioStreamPlayer = main.get_node("BackgroundMusicPlayer")

func _ready() -> void:
	if direction == DIRECTION.LEFT:
		starting_point = point1
		end_point = point2
	elif direction == DIRECTION.RIGHT:
		starting_point = point2
		end_point = point1
	
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var box: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	player.hide()
	create_tween().tween_property(box, "size:x", 768, 0.5)
	create_tween().tween_property(box, "position:x", 192, 0.5)
	slider.global_position.x = starting_point.global_position.x
	distance = round(abs(end_point.global_position.x - slider.global_position.x))
	transition_time = distance / speed

func _process(_delta) -> void:
	if Input.is_action_just_pressed("accept") and tween != null and not has_damaged and not missed and slider != null:
		var weapon: Node2D = weapon_scene.instantiate()
		var slay_animation: AnimatedSprite2D = weapon.get_child(0)
		var damage: float = get_calculated_damage()
		var hurt_value_label: Label = hurt_value_pop_up_animation_scene.instantiate()
		var hurt_value_animation_player: AnimationPlayer = hurt_value_label.get_child(0)
		
		has_damaged = true
		
		tween.kill()
		slider.play("slider_flashing")
		
		villian.add_child(weapon)
		weapon.global_position = villian.global_position
		await time.sleep(ModifiedSpriteFrames.get_animation_absolute_duration(slay_animation, 0), weapon.queue_free)
		
		villian_health_bar.show()
		villian.deal_damage(damage)
		villian.set_rotate(false)
		
		villian.add_child(hurt_value_label)
		hurt_value_label.text = str(round(damage))
		hurt_value_label.self_modulate = Color.RED
		hurt_value_animation_player.play("pop_up")
		
		villian_sprite.rotation_degrees = 0
		
		if villian.health > 0:
			villian.shake()
			Audio.play_sound("damage")
			
			await time.sleep(PAUSE_TIME)
			
			villian.set_rotate(true)
			villian_health_bar.hide()
			hurt_value_label.queue_free()
			slider.stop()
			
			await enemy_turn()
		elif villian.health == 0:
			villian.shake(20)
			Audio.play_sound("damage")
			background_music_player.stop()
			
			await time.sleep(PAUSE_TIME)
			
			villian_health_bar.hide()
			hurt_value_label.queue_free()
			slider.stop()
			slider.queue_free()
			animation_player.play("damage_meter_disappear")
			
			await time.sleep(animation_player.get_current_animation_length() + 1.0)
			
			speech.set_contents([
				[
					"Ha...Ha...Ha...",
					"It seems that you really hate me that much, huh?",
					"As my expectation, my power isn't enough to kill you...",
					"But I am deeply grateful to you for bringing an end to my suffering...",
					"Regrets have been no more, thank you for everything in the past...",
					"Goodbye..."
				],
				[
					"哈。。。哈。。。哈。。。",
					"看来你真的很恨我，对吧？",
					"如我所料，我的能力还不足以杀死你。。。",
					"可是我真的打从心底的感谢你因为你终结了我这长久以来的折磨着与痛苦。。。",
					"再也没有遗憾，感谢你在过去所带给我的一切。。。",
					"再见。。。"
				],
				[
					"哈。。。哈。。。哈。。。",
					"观尔实尔甚憎吾，是乎？",
					"如吾所料，吾之能力尚不足以殺尔。。。",
					"然吾誠自心底感謝尔，因尔終結吾此長久以來之折磨與痛苦。。。",
					"復無有餘悔，感謝尔在過去所帶給吾之一切。。。",
					"再会。。。"
				],
				[
					"Ha...Ha...Ha...",
					"Nampaknya kamu sangat benci akan saya, kan?",
					"Seperti jangkaan saya, kuasa saya tidak cukup untuk bunuh kamu...",
					"Tetapi saya berasa amat bersyurkur kepada kamu kerana telah menamatkan penderitaan saya...",
					"Penyesalan sudah tiada lagi, terima kasih untuk semua pada masa lepas...",
					"Selamat tinggal..."
				],
				[
					"ハハ。。。ハハ。。。ハハ。。。",
					"どうやら本当に私のことを嫌っているようですね？",
					"予想どおり、私の能力はまだあなたを殺すには足りません。。。",
					"しかし、本当に心から感謝します。あなたが私の長い間の苦しみと苦痛を終わらせてくれたことに。。。",
					"もう後悔はありません。過去に私にもたらしてくれたすべてに感謝します。。。",
					"さようなら。。。"
				]
			][db.data.settings.language], 0.1)
			actions.reset()
			queue_free()

func slide_slider() -> void:
	distance = round(abs(end_point.global_position.x - slider.global_position.x))
	transition_time = distance / speed
	tween = create_tween()
	tween.tween_property(slider, "global_position:x", end_point.global_position.x, transition_time)
	tween.finished.connect(enemy_turn)

func enemy_turn() -> void:
	State.set_state(State.MAIN_STATE.COMBATING)
	slider.queue_free()
	if not has_damaged:
		var hurt_value_label: Label = hurt_value_pop_up_animation_scene.instantiate()
		var hurt_value_animation_player: AnimationPlayer = hurt_value_label.get_child(0)
		
		missed = true
		villian.add_child(hurt_value_label)
		hurt_value_label.text = [
			"MISS",
			"描边",
			"未命中",
			"Pengko",
			"ミス"
		][db.data.settings.language]
		hurt_value_animation_player.play("pop_up")
		hurt_value_animation_player.animation_finished.connect(func(_anim_name: StringName) -> void: hurt_value_label.queue_free())
	animation_player.play("damage_meter_disappear")
	await time.sleep(animation_player.get_current_animation_length())
	actions.reset()
	queue_free()

func get_calculated_damage() -> float:
	var damage: float = 0
	var slider_value = (slider.global_position.x - starting_point.global_position.x) / (end_point.global_position.x - starting_point.global_position.x) * 100
	
	if slider_value <= front_meter_range:
		damage = slider_value / front_meter_range * max_damage
	elif slider_value > back_meter_range:
		damage = (front_meter_range + back_meter_range - slider_value) / back_meter_range * max_damage
		
	if damage < min_damage:
		damage = min_damage
	
	return damage
