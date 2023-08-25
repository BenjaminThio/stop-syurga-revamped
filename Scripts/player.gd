extends CharacterBody2D

enum SOUL {
	DETERMINATION,
	INTEGRITY,
	KINDNESS,
	PERSEVERANCE,
	JUSTICE
}
enum DIRECTION {
	HORIZONTAL,
	VERTICAL,
	OMNIDIRECTIONAL
}
enum ANGLE_DIRECTION {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	NULL
}
const SOUL_COLOR: Dictionary = {
	SOUL.DETERMINATION: Color.RED,
	SOUL.INTEGRITY: Color.BLUE,
	SOUL.KINDNESS: Color(0.004, 0.753, 0),
	SOUL.PERSEVERANCE: Color(0.847, 0.204, 0.851),
	SOUL.JUSTICE: Color.YELLOW
}
var is_immuning: bool = false
var perseverance_soul_tween: Tween = null
@export var soul: SOUL = SOUL.DETERMINATION:
	get:
		return soul
	set(value):
		#if get_stack().size() == 1 or get_stack()[1].source == get_script().get_path():
			soul = value
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
@export var speed: int = 150 #100
@export var immunity_time: float = 0.6
@export var jump_force: int = 290
@export var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var shield_angle: int = 0
@export var shield_rotate_time: float = 0.05
@export  var web_index: int = 1

@onready var main: Node2D = get_tree().get_root().get_node("Main")
@onready var heart_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var green: Node2D = $Green
@onready var shield: Area2D = green.get_node("Shield")
@onready var spear_spawner: Node2D = $SpearAttack/Spawner
@onready var bullet_spawnpoint: Marker2D = $BulletSpawnpoint
@onready var webs: Node2D = get_tree().get_first_node_in_group("webs")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
@onready var health_bar: ProgressBar = get_tree().get_first_node_in_group("health_bar")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")

func _ready() -> void:
	update_player()

func _physics_process(_delta) -> void:
	#print(velocity)
	
	if State.current_state != State.MAIN_STATE.COMBATING:
		return
	
	if soul == SOUL.DETERMINATION:
		move(DIRECTION.OMNIDIRECTIONAL)
	elif soul == SOUL.INTEGRITY:
		move(DIRECTION.HORIZONTAL)
		
		if not is_on_floor():
			velocity.y += gravity
		if Input.is_action_pressed("up") and is_on_floor():
			velocity.y = -jump_force
		elif Input.is_action_just_released("up") and velocity.y < -0.1 and not is_on_floor():
			velocity.y = 0
	elif soul == SOUL.KINDNESS:
		if ModifiedInput.either_of_the_actions_just_pressed(["up", "left", "down", "right"]):
			var tween: Tween = create_tween()
			
			shield.monitoring = false
			if Input.is_action_just_pressed("up"):
				shield_angle = get_shield_shortest_rotate_angle(int(shield_angle), ANGLE_DIRECTION.UP)
			elif Input.is_action_just_pressed("right"):
				shield_angle = get_shield_shortest_rotate_angle(int(shield_angle), ANGLE_DIRECTION.RIGHT)
			elif Input.is_action_just_pressed("down"):
				shield_angle = get_shield_shortest_rotate_angle(int(shield_angle), ANGLE_DIRECTION.DOWN)
			elif Input.is_action_just_pressed("left"):
				shield_angle = get_shield_shortest_rotate_angle(int(shield_angle), ANGLE_DIRECTION.LEFT)
			tween.tween_property(shield, "rotation_degrees", shield_angle, shield_rotate_time).finished.connect(func() -> void: shield.monitoring = true)
	elif soul == SOUL.PERSEVERANCE:
		move(DIRECTION.HORIZONTAL)
		
		if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]):
			if Input.is_action_just_pressed("up") and web_index - 1 >= 0:
				web_index -= 1
			elif Input.is_action_just_pressed("down") and web_index + 1 < 3:
				web_index += 1
			if perseverance_soul_tween != null:
				perseverance_soul_tween.kill()
				perseverance_soul_tween = null
			perseverance_soul_tween = create_tween()
			perseverance_soul_tween.tween_property(self, "global_position:y", webs.get_child(web_index).global_position.y, 0.1)
	elif soul == SOUL.JUSTICE:
		move(DIRECTION.OMNIDIRECTIONAL)
		
		if Input.is_action_just_pressed("accept") and visible:
			var bullet: Node = preload("res://Instances/bullet.tscn").instantiate()
			
			canvas.add_child(bullet)
			bullet.global_position = bullet_spawnpoint.global_position
			Audio.play_sound("shoot")

func get_angle_direction(angle: int) -> ANGLE_DIRECTION:
	if angle == 0 or fmod(angle, 360) == 0:
		return ANGLE_DIRECTION.UP
	elif angle == 90 or fmod(angle - 90, 360) == 0:
		return ANGLE_DIRECTION.RIGHT
	elif angle == 180 or fmod(angle - 180, 360) == 0:
		return ANGLE_DIRECTION.DOWN
	elif angle == 270 or fmod(angle - 270, 360) == 0:
		return ANGLE_DIRECTION.LEFT
	else:
		return ANGLE_DIRECTION.NULL

func get_shield_shortest_rotate_angle(current_angle: int, target_direction: ANGLE_DIRECTION) -> int:
	var left_rotate_steps: int = 1
	var right_rotate_steps: int = 1
	
	if get_angle_direction(current_angle) == target_direction:
		return current_angle
	
	while get_angle_direction(current_angle - (90 * left_rotate_steps)) != target_direction:
		left_rotate_steps += 1
	
	while get_angle_direction(current_angle + (90 * right_rotate_steps)) != target_direction:
		right_rotate_steps += 1
	
	if left_rotate_steps < right_rotate_steps:
		return current_angle - (left_rotate_steps * 90)
	else:
		return current_angle + (right_rotate_steps * 90)

func move(direction: DIRECTION) -> void:
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.HORIZONTAL:
		if Input.is_action_pressed("left") and Input.is_action_pressed("right") or Input.is_action_just_released("left") or Input.is_action_just_released("right"):
			velocity.x = 0
		elif Input.is_action_pressed("left"):
			velocity.x = -speed
		elif Input.is_action_pressed("right"):
			velocity.x = speed
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.VERTICAL:
		if Input.is_action_pressed("up") and Input.is_action_pressed("down") or Input.is_action_just_released("up") or Input.is_action_just_released("down"):
			velocity.y = 0
		elif Input.is_action_pressed("up"):
			velocity.y = -speed
		elif Input.is_action_pressed("down"):
			velocity.y = speed
	
	move_and_slide()
	
	"""
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.HORIZONTAL:
		velocity.x = lerp(velocity.x, 0.0, 0.3)
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.VERTICAL:
		velocity.y = lerp(velocity.y, 0.0, 0.3)
	"""

func immunity(sec: float, flashing_time: int = 2) -> void:
	var transition_time = sec / flashing_time / 2
	
	if not is_immuning:
		is_immuning = true
		for _i in range(flashing_time):
			create_tween().tween_property(heart_animated_sprite, "modulate:a", 0.5, transition_time)
			await time.sleep(transition_time)
			create_tween().tween_property(heart_animated_sprite, "modulate:a", 1, transition_time)
			await time.sleep(transition_time)
		is_immuning = false

func ghost_effect() -> void:
	var ghost: Sprite2D = Sprite2D.new()
	var sprite_frames: SpriteFrames = heart_animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	
	ghost.texture = sprite_frames.get_frame_texture(animation_names[0], 0)
	ghost.global_scale = heart_animated_sprite.global_scale
	ghost.self_modulate = SOUL_COLOR[soul]
	add_child(ghost)
	create_tween().tween_property(ghost, "scale", ghost.scale * 2, 0.5)
	create_tween().tween_property(ghost, "self_modulate:a", 0, 0.5)
	await time.sleep(0.5, ghost.queue_free)

func respawn() -> void:
	var spawn_point: Vector2 = Vector2(battlefield.global_position.x + battlefield.pivot_offset.x, battlefield.global_position.y + battlefield.pivot_offset.y)
	
	velocity = Vector2.ZERO
	global_position = spawn_point
	show()

func change_form(new_soul: SOUL) -> void:
	velocity = Vector2.ZERO
	global_position = Vector2(battlefield.global_position.x + battlefield.pivot_offset.x, battlefield.global_position.y + battlefield.pivot_offset.y)
	soul = new_soul
	update_player()
	ghost_effect()

func update_player() -> void:
	heart_animated_sprite.self_modulate = SOUL_COLOR[soul]
	
	if soul == SOUL.KINDNESS:
		green.show()
	elif soul != SOUL.KINDNESS and shield.visible:
		green.hide()
	
	if soul == SOUL.PERSEVERANCE:
		webs.show()
	elif soul != SOUL.PERSEVERANCE and webs.visible:
		webs.hide()
	
	#printt(soul != SOUL.JUSTICE, rotation_degrees > 0, rotation_degrees)
	if soul == SOUL.JUSTICE and rotation_degrees == 0:
		create_tween().tween_property(self, "rotation_degrees", 180, 0.3)
	elif soul != SOUL.JUSTICE:
		if rotation_degrees == -180 or rotation_degrees == 180:
			create_tween().tween_property(self, "rotation_degrees", 0, 0.3)

func deal_damage(damage_value: float) -> void:
	if not is_immuning and State.current_state != State.MAIN_STATE.FLEE and not main.cheat_mode_activated:
		health_bar.deal_damage(damage_value)
		if State.current_state != State.MAIN_STATE.GAME_OVER:
			Audio.play_sound("hurt")
			immunity(immunity_time)
			get_viewport().get_camera_2d().shake()

func heal(heal_value: float) -> void: health_bar.deal_damage(heal_value)

func heart_break():
	heart_animated_sprite.play("split")
	
	await time.sleep(ModifiedSpriteFrames.get_frame_absolute_duration(heart_animated_sprite), func(): Audio.play_sound("heart_split"))
	
	await time.sleep(1)
	
	for _i in range(5):
		var shard: AnimatedSprite2D = load("res://Instances/shard.tscn").instantiate()
		
		shard.global_scale = global_scale
		shard.self_modulate = heart_animated_sprite.self_modulate
		add_child(shard)
	
	heart_animated_sprite.self_modulate.a = 0
	
	Audio.play_sound("heart_shatter")
	
	await time.sleep(1)

func _on_shield_area_entered(area):
	if area.is_in_group("spear") or area.is_in_group("yellow_spear"):
		var bell_sound_duration: float = Audio.play_sound_and_return_length("bell")
		
		if area.is_in_group("spear"):
			spear_spawner.destroy_spear_and_locate_red_spear(area)
		elif area.is_in_group("yellow_spear"):
			spear_spawner.destroy_spear_and_locate_red_spear(area.owner)
		shield.get_node("AnimatedSprite").frame = 1
		
		await time.sleep(bell_sound_duration)
		
		shield.get_node("AnimatedSprite").frame = 0
