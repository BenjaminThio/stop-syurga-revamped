extends Area2D

@export var damage_multiplier: int = 2
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * damage_multiplier)
