extends Node2D

@export var hint_label_show_time: float = 3.5
@export var back_to_intro_time: float = 20.0
@onready var hint_label: Label = $HintLabel

func _ready():
	hint_label.text = [
		"[Press Z or Enter]",
		"[按 Z 或 Enter]",
		"[按 Z 或 Enter]",
		"[Tekan Z atau Enter]",
		"[Z もしくは Enter 押してください]" #"[Z もしくは Enter キーを押してください]"
	][db.data.settings.language]
	hint_label.hide()
	await time.sleep(hint_label_show_time)
	hint_label.show()
	await time.sleep(back_to_intro_time - hint_label_show_time)
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		if db.data.player.name == null:
			get_tree().change_scene_to_file("res://Scenes/new_game.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/main_manu.tscn")
