extends Node

const QUIT_DURATION: float = 1.0
var origin_scene: String = "res://Scenes/main_manu.tscn":
	get:
		var duplicated_origin_scene: String = origin_scene
		
		if origin_scene != "":
			origin_scene = ""
		return duplicated_origin_scene
var reset: bool = false
var quitting_label_scene: PackedScene = preload("res://Instances/quitting_label.tscn")
var has_encountered_villian: bool = false

#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif Input.is_action_just_pressed("quit") or Input.is_action_just_released("quit"):
		var tween: Tween = null
		
		if Input.is_action_just_pressed("quit"):
			var loaded_scene: Node = get_tree().root.get_child(-1)
			var quitting_label: Label = quitting_label_scene.instantiate()
			
			loaded_scene.add_child(quitting_label)
			tween = create_tween()
			tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).tween_property(quitting_label, "self_modulate:a", 1, QUIT_DURATION).finished.connect(get_tree().quit)
			await time.sleep(QUIT_DURATION / 2)
			if is_instance_valid(quitting_label):
				quitting_label.text += "."
		elif Input.is_action_just_released("quit"):
			var quitting_label: Label = get_tree().get_first_node_in_group("quitting_label")
			
			if tween != null:
				tween.kill()
				tween = null
			
			if is_instance_valid(quitting_label):
				quitting_label.queue_free()
