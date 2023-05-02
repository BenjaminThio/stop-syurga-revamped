@tool
extends Sprite2D

@export var fixed_scale: float = 1.0

func _process(_delta) -> void:
	for child in get_children():
		if child.name in ["EpiphysisTop", "EpiphysisBottom"]:
			child.scale = Vector2(fixed_scale / scale.x, fixed_scale / scale.y)

func _on_player_collide(body) -> void:
	if body.is_in_group("player"):
		body.deal_damage(3)
