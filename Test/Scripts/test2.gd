extends Node2D

func _input(event):
	if event is InputEventKey:
		print(InputMap.action_get_events("up")[0].get_physical_keycode_with_modifiers())
		print(event.get_physical_keycode_with_modifiers())
