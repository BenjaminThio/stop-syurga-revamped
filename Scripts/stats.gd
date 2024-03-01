extends HBoxContainer

const max_level: int = 20
const max_hit_points: int = 99
const hit_points_bonus_per_level: int = 4
const base_hit_points: int = 20
const attack_bonus_per_level: int = 2

@export var default_font: FontFile = preload("res://Fonts/Mars_Needs_Cunnilingus.ttf")
@export var default_hp_font: FontFile = preload("res://Fonts/ut-hp-font.ttf")

@onready var name_label: Label = $Name
@onready var level_label: Label = $Level
@onready var hp_label: Label = $HPLabel
@onready var font: FontFile = Global.get_font(default_font)
@onready var hp_font: FontFile = Global.get_font(default_hp_font)

func _ready():
	name_label.text = db.data.player.name
	update_level()
	hp_label.text = [
		"HP",
		"生命值",
		"生命值",
		"HP",
		"エイチピー",
	][db.data.settings.language]
	update_health_label()
	update_font()

func update_health_label() -> void:
	var health_label: Label = $HealthLabel
	
	health_label.text = "{health} / {max_health}".format({"health": PlayerData.health, "max_health": PlayerData.max_health})

func update_level() -> void:
	level_label.text = [
		"LV {level}".format({"level": db.get_player_level()}),
		"{level} 级".format({"level": db.get_player_level()}),
		"{level} 品".format({"level": db.get_player_level()}),
		"TAHAP {level}".format({"level": db.get_player_level()}),
		"{level} レベル".format({"level": db.get_player_level()})
	][db.data.settings.language]

func update_font():
	for label in get_children():
		if label is Label:
			if label != hp_label:
				label.add_theme_font_override("font", font)
			else:
				label.add_theme_font_override("font", hp_font)
