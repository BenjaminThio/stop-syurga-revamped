extends Control

@onready var exit_label: Label = $Exit

func _ready():
	exit_label.text = [
		"Exit",
		"退出",
		"辍",
		"Keluar",
		"辞める"
	][db.data.settings.language]

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		get_tree().change_scene_to_file("res://Scenes/main_manu.tscn")
