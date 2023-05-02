class_name Item extends Node

var item_name: String
var heal_value: int
var damage_increase: int
var defence_increase: int

func _init(new_item_name: String, new_heal_value: int, new_damage_increase: int = 0, new_defence_increase: int = 0) -> void:
	item_name = new_item_name
	heal_value = new_heal_value
	damage_increase = new_damage_increase
	defence_increase = new_defence_increase

func fulfill_effect(health_bar: ProgressBar) -> void:
	if heal_value > 0:
		health_bar.heal(heal_value)
	elif heal_value < 0:
		health_bar.deal_damage(heal_value)
