@tool
extends Area2D

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
var original_attack_type: ATTACK_TYPE = ATTACK_TYPE.LIGHT_BLUE_ATTACK
#var light_deal_damage: bool = true
@export var attack_type: ATTACK_TYPE = ATTACK_TYPE.WHITE_ATTACK:
	get:
		return attack_type
	set(value):
		attack_type = value
		update_light()
@export var damage_multiplier: int = 3
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")

"""
func _process(_delta):
	if not Engine.is_editor_hint() and Input.is_action_just_pressed("flashlight"):
		light_deal_damage = not light_deal_damage
"""

func update_light():
	var color_rect: ColorRect = $ColorRect
	
	color_rect.self_modulate = ATTACK_TYPE_COLOR[attack_type]

func _on_body_entered(body):
	if not Engine.is_editor_hint() and body.is_in_group("player"):# and light_deal_damage:
		match attack_type:
			ATTACK_TYPE.WHITE_ATTACK:
				body.deal_damage(villain.attack * damage_multiplier)
			ATTACK_TYPE.LIGHT_BLUE_ATTACK:
				if Vector2i(body.velocity) > Vector2i.ZERO or Vector2i(body.velocity) < Vector2i.ZERO:
					body.deal_damage(villain.attack * damage_multiplier)
			ATTACK_TYPE.ORANGE_ATTACK:
				if Vector2i(body.velocity) == Vector2i.ZERO:
					body.deal_damage(villain.attack * damage_multiplier)
