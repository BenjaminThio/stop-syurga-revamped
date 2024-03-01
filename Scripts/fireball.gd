extends Area2D

var rotation_vector: Vector2 = Vector2.ZERO
var flipping_sprite: bool = false
var is_moving: bool = false
var spawner_id: int

@export var speed: int = 300
#@export var move_delay_duration: float = 2.0
@export var flip_duration: float = 0.1
@export var damage_multiplier: int = 3

@onready var sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var dummy_player = get_tree().get_first_node_in_group("dummy_player")
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")

"""
func _ready():
	await time.sleep(move_delay_duration)
	get_rotation_vector()
"""

func _process(delta):
	translate(rotation_vector * speed * delta)
	if not flipping_sprite:
		flipping_sprite = true
		await time.sleep(flip_duration)
		sprite.flip_h = not sprite.flip_h
		flipping_sprite = false

func get_rotation_vector():
	if is_moving:
		return
	else:
		is_moving = true
	
	if player != null:
		look_at(player.global_position)
	elif dummy_player != null:
		look_at(dummy_player.global_position)
	else:
		look_at(get_global_mouse_position())
	sprite.rotation_degrees = -rotation_degrees
	rotation_vector = Vector2(1, 0).rotated(rotation)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * damage_multiplier)

func _on_fireball_screen_exited():
	queue_free()
