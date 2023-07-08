extends Area2D

@export var rotate_speed: int = 100
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")

func _process(delta):
	rotation_degrees += PI * rotate_speed * delta
	if rotation_degrees >= 360:
		rotation_degrees = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack)
