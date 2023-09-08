extends HBoxContainer

@export var colors: Array[Color] = [Color.YELLOW, Color.RED, Color.BLUE, Color(0.004, 0.753, 0), Color(0.847, 0.204, 0.851)]
@export var color_switch_duration: float = 0.5
var color_switching_activated: bool = false
var is_color_switching: bool = false

func _process(_delta):
	if color_switching_activated and not is_color_switching:
		is_color_switching = true
		colors.append(colors[0])
		colors.pop_at(0)
		render()
		await time.sleep(color_switch_duration)
		is_color_switching = false

func render():
	for char_index in range(get_child_count()):
		get_child(char_index).set("theme_override_colors/font_color", colors[char_index])
