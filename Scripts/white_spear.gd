extends Area2D

var rotateable: bool = false
var look_at_target: bool = false
var moveable: bool = false
var rotation_vector: Vector2 = Vector2.ZERO

@export var transition_duration: float = 0.5
#@export var rotate_delay_duration: float = 0.2
@export var move_delay_duration: float = 0.4
@export var speed: int = 300
@export var damage_multiplier: int = 2

@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _ready():
	modulate.a = 0
	
	await time.sleep(0.001)
	
	if is_instance_valid(player):
		look_at(player.global_position)
	else:
		look_at(get_global_mouse_position())
	rotation_degrees -= 180
	
	#await time.sleep(rotate_delay_duration)
	
	rotateable = true

func _process(delta):
	if rotateable and not look_at_target:
		var original_rotation: float = rotation_degrees
		var target_rotation: float
		
		rotateable = false
		if is_instance_valid(player):
			look_at(player.global_position)
		else:
			look_at(get_global_mouse_position())
		target_rotation = rotation_degrees
		rotation_degrees = original_rotation
		Audio.play_sound("spearappear")
		create_tween().tween_property(self, "modulate:a", 1, transition_duration)
		create_tween().tween_property(self, "rotation_degrees", target_rotation, transition_duration).finished.connect(
			func() -> void:
				look_at_target = true
				
				await time.sleep(move_delay_duration)
				
				look_at_target = false
				rotation_vector = Vector2(1, 0).rotated(rotation)
				moveable = true
				Audio.play_sound("arrow")
		)
		
	if look_at_target:
		if is_instance_valid(player):
			look_at(player.global_position)
		else:
			look_at(get_global_mouse_position())
	
	if moveable:
		translate(rotation_vector * speed * delta)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack * damage_multiplier)

func _on_screen_exited():
	queue_free()
