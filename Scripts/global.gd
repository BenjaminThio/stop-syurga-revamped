extends Node

var origin_scene: String = "res://Scenes/main_manu.tscn":
	get:
		var duplicated_origin_scene: String = origin_scene
		
		if origin_scene != "":
			origin_scene = ""
		return duplicated_origin_scene
var reset: bool = false

#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
