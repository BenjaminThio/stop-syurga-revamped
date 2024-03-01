@tool
extends Sprite2D

enum ATTACK_TYPE {
	WHITE_ATTACK,
	LIGHT_BLUE_ATTACK,
	ORANGE_ATTACK
}
const ATTACK_TYPE_COLOR: Dictionary = {
	ATTACK_TYPE.WHITE_ATTACK: Color(1.0, 1.0, 1.0),
	ATTACK_TYPE.LIGHT_BLUE_ATTACK: Color(0.08, 0.66, 1.0),
	ATTACK_TYPE.ORANGE_ATTACK: Color(1.0, 0.64, 0.24)
}
@export var attack_type: ATTACK_TYPE = ATTACK_TYPE.WHITE_ATTACK:
	get:
		return attack_type
	set(value):
		attack_type = value
		update_bone()
@export var fixed_scale: float = 1.0
@export var damage_multiplier: int = 2

@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")

func _process(_delta) -> void:
	for child in get_children():
		if child.name in ["EpiphysisTop", "EpiphysisBottom"]:
			child.scale = Vector2(fixed_scale / scale.x, fixed_scale / scale.y)

func update_bone():
	modulate = ATTACK_TYPE_COLOR[attack_type]

func _on_player_collide(body) -> void:
	if not Engine.is_editor_hint() and body.is_in_group("player"):
		#if not body.is_immuning:
		#	queue_free()
		match attack_type:
			ATTACK_TYPE.WHITE_ATTACK:
				body.deal_damage(villain.attack * damage_multiplier)
			ATTACK_TYPE.LIGHT_BLUE_ATTACK:
				if Vector2i(body.velocity) > Vector2i.ZERO or Vector2i(body.velocity) < Vector2i.ZERO:
					body.deal_damage(villain.attack * damage_multiplier)
			ATTACK_TYPE.ORANGE_ATTACK:
				if Vector2i(body.velocity) == Vector2i.ZERO:
					body.deal_damage(villain.attack * damage_multiplier)
