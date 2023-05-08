extends HBoxContainer

const max_level: int = 20
const max_hit_points: int = 99
const hit_points_bonus_per_level: int = 4
const base_hit_points: int = 20
const attack_bonus_per_level: int = 2

@onready var name_label: Label = $Name
@onready var level_label: Label = $Level

func _ready():
	name_label.text = db.player_name
	level_label.text = "LV {level}".format({"level": db.level})
	update_health_label()

func update_health_label() -> void:
	var health_label: Label = $HealthLabel
	
	health_label.text = "{health} / {max_health}".format({"health": db.health, "max_health": db.max_health})
