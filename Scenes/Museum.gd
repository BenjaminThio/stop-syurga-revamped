extends Node3D

func _on_body_entered_teleporter(body):
	if body.is_in_group("player"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://Scenes/main_manu.tscn")
