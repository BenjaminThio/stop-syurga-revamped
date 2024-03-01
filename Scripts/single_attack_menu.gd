extends VBoxContainer

enum SINGLE_ATTACK {
	BONE_CURVE,
	RANDOM_NORMAL_SPEAR,
	RANDOM_YELLOW_SPEAR,
	METTATON_LEG,
	REWINDABLE_METTATON_LEG,
	RANDOM_SPIDER,
	DISCO_BALL_WHITE_LIGHT_AND_BLUE,
	REWINDABLE_FALLING_BLOCK_AND_BOMB,
	FALLING_BARRIER_AND_BOMB,
	BOOMERANG_CROISSANT,
	SPIDER_GAP,
	BONE_LIGHT_BLUE_AND_ORANGE,
	FIREBALL,
	FLYING_SPEAR,
	RANDOM_NORMAL_AND_YELLOW_SPEAR,
	FAST_NORMAL_AND_YELLOW_SPEAR,
	OMNIDIRECTIONAL_NORMAL_AND_OPPOSITE_YELLOW_SPEAR,
	DISCO_BALL_WHITE_AND_LIGHT_BLUE_AND_ORANGE,
	RISING_SPEAR,
	SPEAR_SWIRL
}
const SOUL_COLOR_IN_EVERY_SINGLE_ATTACK: Array[Color] = [
	Color.BLUE,
	Color(0.004, 0.753, 0),
	Color(0.004, 0.753, 0),
	Color.YELLOW,
	Color.YELLOW,
	Color(0.847, 0.204, 0.851),
	Color.YELLOW,
	Color.YELLOW,
	Color.YELLOW,
	Color(0.847, 0.204, 0.851),
	Color(0.847, 0.204, 0.851),
	Color.BLUE,
	Color.RED,
	Color.RED,
	Color(0.004, 0.753, 0),
	Color(0.004, 0.753, 0),
	Color(0.004, 0.753, 0),
	Color.YELLOW,
	Color.RED,
	Color.RED
]
const soul_gap: int = 25
const easter_egg_trigger_condition: Array[Color] = [Color.RED, Color.BLUE, Color(0.004, 0.753, 0), Color(0.847, 0.204, 0.851), Color.YELLOW]
var highlighted_single_attack_index: SINGLE_ATTACK = SINGLE_ATTACK.BONE_CURVE
var on_menu: bool = true
var color_password: Array[Color] = []
var dtm_mono_font: FontFile = preload("res://Fonts/DTM-Mono.otf")

@onready var soul: Sprite2D = owner.get_node("Soul")
@onready var exit_chars: HBoxContainer = owner.get_node("ExitChars")

func _ready():
	for single_attack_name in SINGLE_ATTACK.keys():
		var new_single_attack_label: Label = Label.new()
		
		new_single_attack_label.text = single_attack_name
		#new_single_attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_single_attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_single_attack_label.add_theme_font_override("font", dtm_mono_font)
		new_single_attack_label.add_theme_font_size_override("font_size", 18)
		add_child(new_single_attack_label)
	
	await get_tree().process_frame
	
	highlight_single_attack()

@warning_ignore("int_as_enum_without_cast")
func _process(_delta):
	if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]) and on_menu:
		if Input.is_action_just_pressed("up"):
			if highlighted_single_attack_index - 1 >= 0:
				highlighted_single_attack_index -= 1
			else:
				highlighted_single_attack_index = SINGLE_ATTACK.size() - 1
		elif Input.is_action_just_pressed("down"):
			if highlighted_single_attack_index + 1 < SINGLE_ATTACK.size():
				highlighted_single_attack_index += 1
			else:
				highlighted_single_attack_index = 0
		
		highlight_single_attack()
		Audio.play_sound("squeak")
	elif ModifiedInput.either_of_the_actions_just_pressed(["left", "right"]):
		on_menu = not on_menu
		if on_menu:
			if exit_chars.color_switching_activated:
				exit_chars.color_switching_activated = false
			for exit_char in exit_chars.get_children():
				exit_char.set("theme_override_colors/font_color", Color.WHITE)
			highlight_single_attack()
			soul.show()
		else:
			if color_password.size() + 1 <= easter_egg_trigger_condition.size():
				color_password.append(SOUL_COLOR_IN_EVERY_SINGLE_ATTACK[highlighted_single_attack_index])
			reset_single_attack_labels_color()
			soul.hide()
			if color_password == easter_egg_trigger_condition:
				exit_chars.color_switching_activated = true
			else:
				if exit_chars.color_switching_activated:
					exit_chars.color_switching_activated = false
				for exit_char in exit_chars.get_children():
					exit_char.set("theme_override_colors/font_color", SOUL_COLOR_IN_EVERY_SINGLE_ATTACK[highlighted_single_attack_index]) #Color.YELLOW)
		Audio.play_sound("squeak")
	elif Input.is_action_just_pressed("accept"):
		if on_menu:
			var select_sound_length: float = Audio.play_sound_and_return_length("select")
			
			Global.loop_attack_index = highlighted_single_attack_index
			PlayerData.items_reset()
			
			await time.sleep(select_sound_length)
			
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
		elif color_password == easter_egg_trigger_condition:
			get_tree().change_scene_to_file("res://Scenes/easter_egg.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func reset_single_attack_labels_color():
	for single_attack_label in get_children():
		single_attack_label.set("theme_override_colors/font_color", Color.WHITE)

func highlight_single_attack():
	var highlighted_single_attack_label: Label = get_child(highlighted_single_attack_index)
	
	reset_single_attack_labels_color()
	highlighted_single_attack_label.set("theme_override_colors/font_color", SOUL_COLOR_IN_EVERY_SINGLE_ATTACK[highlighted_single_attack_index]) #Color.YELLOW)
	
	soul.global_position = Vector2(highlighted_single_attack_label.global_position.x - soul_gap, highlighted_single_attack_label.global_position.y + (highlighted_single_attack_label.size.y / 2))
	soul.self_modulate = SOUL_COLOR_IN_EVERY_SINGLE_ATTACK[highlighted_single_attack_index]
