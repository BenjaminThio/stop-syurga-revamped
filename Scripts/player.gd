extends CharacterBody2D

const SPEED: int = 100
const JUMP_FORCE: int = 290
const SOUL: Dictionary = {
	RED = Color.RED,
	BLUE = Color.BLUE,
	GREEN = Color(0.004, 0.753, 0),
	PURPLE = Color(0.847, 0.204, 0.851),
	YELLOW = Color.YELLOW
}
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var soul: Color = SOUL.RED
var rope_index: int = 1
var immunity_time: float = 1.8

@onready var main: Node2D = get_tree().get_root().get_node("Main")
@onready var heart_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield: Node2D = $Shield
@onready var shoot_point: Marker2D = $Marker2D

enum DIRECTION {
	HORIZONTAL,
	VERTICAL,
	OMNIDIRECTIONAL
}

func _ready() -> void:
	heart_animated_sprite.self_modulate = SOUL.RED
	shield.hide()
	get_tree().get_first_node_in_group("ropes").hide()
	if soul == SOUL.YELLOW:
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 180, 0.3)
	if soul == SOUL.GREEN:
		shield.show()
	elif soul == SOUL.PURPLE:
		get_tree().get_first_node_in_group("ropes").show()

func _physics_process(_delta) -> void:
	if State.current_state != State.COMBATING:
		return
	
	if soul == SOUL.RED:
		Move(DIRECTION.OMNIDIRECTIONAL)
	elif soul == SOUL.BLUE:
		Move(DIRECTION.HORIZONTAL)
		
		if not is_on_floor():
			velocity.y += gravity
		if Input.is_action_pressed("up") and is_on_floor():
			velocity.y = -JUMP_FORCE
		elif Input.is_action_just_released("up") and velocity.y < -0.1 and not is_on_floor():
			velocity.y = 0
	elif soul == SOUL.GREEN:
		if ModifiedInput.either_of_the_actions_just_pressed(["up", "left", "down", "right"]):
			var tween: Tween = create_tween()
			if Input.is_action_just_pressed("up"):
				tween.tween_property(shield, "rotation_degrees", 0, 0.1)
			elif Input.is_action_just_pressed("left"):
				tween.tween_property(shield, "rotation_degrees", 270, 0.1)
			elif Input.is_action_just_pressed("down"):
				tween.tween_property(shield, "rotation_degrees", 180, 0.1)
			elif Input.is_action_just_pressed("right"):
				tween.tween_property(shield, "rotation_degrees", 90, 0.1)
			tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	elif soul == SOUL.PURPLE:
		Move(DIRECTION.HORIZONTAL)
		
		if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]):
			if Input.is_action_just_pressed("up") and rope_index - 1 >= 0:
				rope_index -= 1
			elif Input.is_action_just_pressed("down") and rope_index + 1 < 3:
				rope_index += 1
			create_tween().tween_property(self, "global_position:y", get_tree().get_first_node_in_group("ropes").get_child(rope_index).global_position.y, 0.1)
	elif soul == SOUL.YELLOW:
		Move(DIRECTION.OMNIDIRECTIONAL)
		
		if Input.is_action_just_pressed("shoot"):
			var bullet: Node = preload("res://Instances/bullet.tscn").instantiate()
			get_tree().get_first_node_in_group("canvas").add_child(bullet)
			bullet.global_position = shoot_point.global_position

func Move(direction: int) -> void:
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.HORIZONTAL:
		if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
			velocity.x = 0
		elif Input.is_action_pressed("left"):
			velocity.x = -SPEED
		elif Input.is_action_pressed("right"):
			velocity.x = SPEED
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.VERTICAL:
		if Input.is_action_pressed("up") and Input.is_action_pressed("down"):
			velocity.y = 0
		elif Input.is_action_pressed("up"):
			velocity.y = -SPEED
		elif Input.is_action_pressed("down"):
			velocity.y = SPEED
	
	move_and_slide()
	
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.HORIZONTAL:
		velocity.x = lerp(velocity.x, 0.0, 0.3)
	if direction == DIRECTION.OMNIDIRECTIONAL or direction == DIRECTION.VERTICAL:
		velocity.y = lerp(velocity.y, 0.0, 0.3)

var is_immuning: bool = false

func immunity(sec: float, flashing_time: int = 3) -> void:
	var transition_time = sec / flashing_time / 2
	
	if not is_immuning:
		is_immuning = true
		for _i in range(flashing_time):
			create_tween().tween_property(self, "modulate:a", 0.5, transition_time)
			await time.sleep(transition_time)
			create_tween().tween_property(self, "modulate:a", 1, transition_time)
			await time.sleep(transition_time)
		is_immuning = false

func ghost_effect() -> void:
	var ghost: Sprite2D = Sprite2D.new()
	var sprite_frames: SpriteFrames = heart_animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	
	ghost.texture = sprite_frames.get_frame_texture(animation_names[0], 0)
	ghost.global_scale = heart_animated_sprite.global_scale
	ghost.self_modulate = soul
	add_child(ghost)
	create_tween().tween_property(ghost, "scale", ghost.scale * 2, 0.5)
	create_tween().tween_property(ghost, "self_modulate:a", 0, 0.5)
	await time.sleep(0.5, ghost.queue_free)

func respawn() -> void:
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	var spawn_point: Vector2 = Vector2(battlefield.global_position.x + battlefield.pivot_offset.x, battlefield.global_position.y + battlefield.pivot_offset.y)
	
	global_position = spawn_point
	show()

func change_form(new_soul: Color):
	soul = new_soul
	heart_animated_sprite.self_modulate = soul
	shield.hide()
	get_tree().get_first_node_in_group("ropes").hide()
	if soul == SOUL.YELLOW:
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 180, 0.3)
	else:
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 0, 0.3)
	if soul == SOUL.GREEN:
		shield.show()
	elif soul == SOUL.PURPLE:
		get_tree().get_first_node_in_group("ropes").show()
	velocity = Vector2.ZERO
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	global_position = Vector2(battlefield.global_position.x + battlefield.pivot_offset.x, battlefield.global_position.y + battlefield.pivot_offset.y)
	ghost_effect()

func deal_damage(damage_value: float) -> void:
	if not is_immuning:
		get_tree().get_first_node_in_group("health_bar").deal_damage(damage_value)
		if State.current_state != State.GAME_OVER:
			main.play_sound_effect("hurt")
			immunity(immunity_time)
			get_viewport().get_camera_2d().camera_shake()

func heal(heal_value: float) -> void: get_tree().get_first_node_in_group("health_bar").deal_damage(heal_value)

func heart_break():
	heart_animated_sprite.play("split")
	
	await time.sleep(ModifiedSpriteFrames.get_frame_absolute_duration(heart_animated_sprite), func(): main.play_sound_effect("Heart Split"))
	
	await time.sleep(1)
	
	for _i in range(5):
		var shard: AnimatedSprite2D = load("res://Instances/shard.tscn").instantiate()
		
		shard.global_scale = global_scale
		shard.self_modulate = heart_animated_sprite.self_modulate
		add_child(shard)
	
	heart_animated_sprite.self_modulate.a = 0
	
	main.play_sound_effect("Heart Shatter")
	
	await time.sleep(1)
