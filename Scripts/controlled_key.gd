extends Control

const ONE_GRID_BOX_PIXELS: int = 8

@export var default_font: FontFile = preload("res://Fonts/DTM-Mono.otf")

@onready var key: Button = $Key
@onready var key_original_height: float = key.size.y
@onready var key_original_y_position: float = key.position.y

var normal_style: StyleBox = preload("res://StyleBoxes/normal_key_button.tres")
var normal_pressed_style: StyleBoxFlat = preload("res://StyleBoxes/normal_pressed_key_button.tres")
var input_map: ScrollContainer
var action: StringName = ""
var input_event: InputEvent
var input_event_listener: InputEvent = null
var is_key_shaking: bool = false

func _ready():
	update_font()
	
	if get_parent().get_parent() != null:
		input_map = get_parent().get_parent().get_parent().get_parent()

func _input(event):
	if key.button_pressed and event is InputEventKey and event.is_pressed() and not event.is_echo():
		#print(event.is_match(input_event, false))
		if event.physical_keycode == input_event.physical_keycode or not input_map.is_any_action_contains_event(event):
			if key.text != event.as_text():
				key.text = event.as_text()
				input_event_listener = null
			
			if not input_map.is_any_action_contains_event(event):
				input_event_listener = event
		else:
			loop_shake(key)
			#print("Event used!")

func update_font():
	key.add_theme_font_override("font", Global.get_font(default_font))

func set_input_event(new_input_event: InputEvent):
	input_event = new_input_event
	$Key.text = new_input_event.as_text().replace(" (Physical)", "")

func _on_key_button_pressed():
	input_map.set_input_listener_activated(key.button_pressed)
	
	if not key.button_pressed and input_event_listener != null:
		InputMap.action_erase_event(action, input_event)
		InputMap.action_add_event(action, input_event_listener)
		input_event_listener = null
		input_map.update_input_map()
		db.data.settings.input_map = Global.get_input_map()
		db.save_data()

func _on_key_button_down():
	key_pressed()

func _on_key_button_up():
	if not key.button_pressed:
		key_released()

func _on_key_resized():
	custom_minimum_size.x = $Key.size.x + (ONE_GRID_BOX_PIXELS * 2)

func key_pressed():
	key.add_theme_stylebox_override("normal", normal_pressed_style)
	key.size.y = key_original_height - ONE_GRID_BOX_PIXELS
	key.position.y = key_original_y_position + ONE_GRID_BOX_PIXELS

func key_released():
	key.add_theme_stylebox_override("normal", normal_style)
	key.size.y = key_original_height
	key.position.y = key_original_y_position

func disabled():
	if not key.button_pressed:
		key.disabled = true

func enabled():
	key.disabled = false

func loop_shake(target: Control, offset_value: float = 1.0, delay_time: float = 0.03, times: int = 10) -> void:
	if not is_key_shaking:
		is_key_shaking = true
		
		for _i in range(times):
			await shake(target, offset_value, delay_time)
		
		if not key.button_pressed:
			key_released()
		
		is_key_shaking = false

func shake(target: Control, offset_value: float = 1.0, delay_time: float = 0.03) -> void:
	var target_origin: Vector2 = target.position
	
	target.position = Vector2(target_origin.x + generate_random_shake_offset(offset_value), target_origin.y + generate_random_shake_offset(offset_value))
	await time.sleep(delay_time)
	target.position = target_origin

func generate_random_shake_offset(offset_value: float) -> float:
	var offset_values: PackedFloat32Array = [-offset_value, offset_value]
	
	return random.choice(offset_values)

"""
if event is InputEventMouseMotion and is_key_down:
	if event.position.x < global_position.x or event.position.x > global_position.x + size.x or event.position.y < global_position.y or event.position.y > global_position.y + size.y:
		key.add_theme_stylebox_override("normal", normal_pressed_style)
"""
