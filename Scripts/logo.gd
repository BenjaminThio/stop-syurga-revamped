extends Node2D

@export var default_font: FontFile = preload("res://Fonts/crypt-of-tomorrow-ut-font-no-rus.ttf")
@export var hint_label_show_time: float = 3.5
@export var back_to_intro_time: float = 20.0
@onready var hint_label: Label = $HintLabel

func _ready():
	var accept_events_name: Array[StringName] = []
	
	for accept_action_event in InputMap.action_get_events("accept") as Array[InputEvent]:
		accept_events_name.append(Global.translate_input(accept_action_event.as_text().replace(" (Physical)", "").to_lower()))
	
	hint_label.add_theme_font_override("font", Global.get_font(default_font))
	hint_label.text = [
		"[Press {first_accept_event} or {second_accept_event}]".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[按 {first_accept_event} 或 {second_accept_event}]".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[按 {first_accept_event} 或 {second_accept_event}]".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[Tekan {first_accept_event} atau {second_accept_event}]".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[{first_accept_event} もしくは {second_accept_event} 押してください]".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]})
	][db.data.settings.language]
	"""
		"[Press Z or Enter]",
		"[按 Z 或 Enter]",
		"[按 Z 或 Enter]",
		"[Tekan Z atau Enter]",
		"[Z もしくは Enter 押してください]" #"[Z もしくは Enter キーを押してください]"
	"""
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
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
