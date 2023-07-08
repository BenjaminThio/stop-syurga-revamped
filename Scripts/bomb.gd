extends Area2D

@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		area.queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack)
