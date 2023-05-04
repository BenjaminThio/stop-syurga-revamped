extends CharacterBody2D

const SPEED: int = 100
const JUMP_FORCE: int = 290
const COLORS: Dictionary = {
	"red": Color.RED,
	"blue": Color.BLUE,
	"green": Color(0.004, 0.753, 0),
	"purple": Color(0.847, 0.204, 0.851),
	"yellow": Color.YELLOW
}
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var color: String = "red"
var rope_index: int = 1
var immunity_time: float = 1.8

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var shield: Node2D = $Shield
@onready var shoot_point: Marker2D = $Marker2D

func _ready() -> void:
	animated_sprite.self_modulate = COLORS[color]
	shield.hide()
	get_tree().get_first_node_in_group("ropes").hide()
	if color == "yellow":
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 180, 0.3)
	if color == "green":
		shield.show()
	elif color == "purple":
		get_tree().get_first_node_in_group("ropes").show()

func _physics_process(_delta) -> void:
	if State.current_state != State.COMBATING:
		return
	
	if color == "red":
		Move("omnidirectional")
	elif color == "blue":
		Move("horizontal")
		
		if not is_on_floor():
			velocity.y += gravity
		if Input.is_action_pressed("up") and is_on_floor():
			velocity.y = -JUMP_FORCE
		elif Input.is_action_just_released("up") and velocity.y < -0.1 and not is_on_floor():
			velocity.y = 0
	elif color == "green":
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
	elif color == "purple":
		Move("horizontal")
		
		if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]):
			if Input.is_action_just_pressed("up") and rope_index - 1 >= 0:
				rope_index -= 1
			elif Input.is_action_just_pressed("down") and rope_index + 1 < 3:
				rope_index += 1
			create_tween().tween_property(self, "global_position:y", get_tree().get_first_node_in_group("ropes").get_child(rope_index).global_position.y, 0.1)
	elif color == "yellow":
		Move("omnidirectional")
		
		if Input.is_action_just_pressed("shoot"):
			var bullet: Node = preload("res://Instances/bullet.tscn").instantiate()
			get_tree().get_first_node_in_group("canvas").add_child(bullet)
			bullet.global_position = shoot_point.global_position

func Move(direction) -> void:
	if direction == "omnidirectional" or direction == "horizontal":
		if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
			velocity.x = 0
		elif Input.is_action_pressed("left"):
			velocity.x = -SPEED
		elif Input.is_action_pressed("right"):
			velocity.x = SPEED
	if direction == "omnidirectional" or direction == "vertical":
		if Input.is_action_pressed("up") and Input.is_action_pressed("down"):
			velocity.y = 0
		elif Input.is_action_pressed("up"):
			velocity.y = -SPEED
		elif Input.is_action_pressed("down"):
			velocity.y = SPEED
	
	move_and_slide()
	
	if direction == "omnidirectional" or direction == "horizontal":
		velocity.x = lerp(velocity.x, 0.0, 0.3)
	if direction == "omnidirectional" or direction == "vertical":
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
	var sprite_frames: SpriteFrames = animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	
	ghost.texture = sprite_frames.get_frame_texture(animation_names[0], 0)
	ghost.global_scale = animated_sprite.global_scale
	ghost.self_modulate = COLORS[color]
	add_child(ghost)
	create_tween().tween_property(ghost, "scale", ghost.scale * 2, 0.5)
	create_tween().tween_property(ghost, "self_modulate:a", 0, 0.5)
	await time.sleep(0.5, ghost.queue_free)

func respawn() -> void:
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	var spawn_point: Vector2 = Vector2(battlefield.global_position.x + battlefield.pivot_offset.x, battlefield.global_position.y + battlefield.pivot_offset.y)
	
	global_position = spawn_point
	show()

func change_form(newColor: String):
	color = newColor
	animated_sprite.self_modulate = COLORS[color]
	shield.hide()
	get_tree().get_first_node_in_group("ropes").hide()
	if color == "yellow":
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 180, 0.3)
	else:
		var tween: Tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 0, 0.3)
	if color == "green":
		shield.show()
	elif color == "purple":
		get_tree().get_first_node_in_group("ropes").show()
	velocity = Vector2.ZERO
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	global_position = Vector2(battlefield.global_position.x + battlefield.pivot_offset.x, battlefield.global_position.y + battlefield.pivot_offset.y)
	ghost_effect()

func deal_damage(damage_value: float) -> void:
	if not is_immuning:
		get_tree().get_root().get_node("Main").play_sound_effect("hurt")
		immunity(immunity_time)
		get_viewport().get_camera_2d().camera_shake()
		get_tree().get_first_node_in_group("health_bar").deal_damage(damage_value)

func heal(heal_value: float) -> void: get_tree().get_first_node_in_group("health_bar").deal_damage(heal_value)
