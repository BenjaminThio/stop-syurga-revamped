extends Control

@export var default_font: FontFile = preload("res://Fonts/DTM-Sans.otf")

@onready var exit_label: Label = $Exit

func _ready():
	exit_label.add_theme_font_override("font", Global.get_font(default_font))
	exit_label.text = [
		"Exit",
		"退出",
		"辍",
		"Keluar",
		"辞める"
	][db.data.settings.language]

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
