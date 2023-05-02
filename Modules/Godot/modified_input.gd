class_name ModifiedInput extends Node

static func either_of_the_actions_just_pressed(actions: Array[String]) -> bool:
	for action in actions:
		if Input.is_action_just_pressed(action):
			return true
	return false
