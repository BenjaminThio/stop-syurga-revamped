extends Node3D

@onready var statue: Sprite3D = $Statue
@onready var camera: Camera3D = $Player/Head/Camera3D

func _on_body_entered_teleporter(body):
	if body.is_in_group("player"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file.call_deferred("res://Scenes/main_menu.tscn")

func _process(_delta):
	statue.look_at(camera.global_transform.origin, Vector3.UP)
	statue.rotation_degrees.x = 0
	statue.rotation_degrees.z = 0
