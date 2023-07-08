extends Node2D

enum OPTION {
	BEGIN_GAME,
	SETTINGS
}
var highlighted_option: int = 0
@onready var main = get_tree().get_root().get_node("NewGame")

func _ready():
	highlight_option()

func _process(_delta):
	if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]):
		if Input.is_action_just_pressed("up") and highlighted_option - 1 >= 0:
			highlighted_option -= 1
		elif Input.is_action_just_pressed("down") and highlighted_option + 1 < get_child_count():
			highlighted_option += 1
		reset_options()
		highlight_option()
	elif Input.is_action_just_pressed("accept"):
		if highlighted_option == OPTION.BEGIN_GAME:
			main.activate_scene(main.SCENE.NAME)
		elif highlighted_option == OPTION.SETTINGS:
			Global.origin_scene = get_tree().current_scene.scene_file_path
			get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func highlight_option():
	get_child(highlighted_option).set("theme_override_colors/font_color", Color.YELLOW)

func reset_options():
	for option in get_children():
		option.set("theme_override_colors/font_color", Color.WHITE)
