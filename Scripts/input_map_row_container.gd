extends HBoxContainer

@export var default_font: FontFile = preload("res://Fonts/DTM-Sans.otf")

@onready var action_label: Label = $Action
@onready var key_container: HBoxContainer = $KeyContainer

var controlled_key_packed_scene: PackedScene = preload("res://Instances/controlled_key.tscn")
var action: StringName:
	get:
		return action
	set(value):
		action = value
		update_action_label_by_language()
var input_events: Array[InputEvent]:
	get:
		return input_events
	set(value):
		input_events = value
		update_keys()

func _ready():
	update_font()

func update_action_label_by_language():
	action_label.text = Global.translate_input(action)
	update_font()
	for key in key_container.get_children() as Array[HBoxContainer]:
		key.update_font()

func update_font():
	action_label.add_theme_font_override("font", Global.get_font(default_font))

func update_keys():
	for input_event in input_events:
		var controlled_key: Control = controlled_key_packed_scene.instantiate()
		
		controlled_key.action = action
		controlled_key.set_input_event(input_event)
		key_container.add_child(controlled_key)

func disable_all_keys():
	for key in key_container.get_children() as Array[HBoxContainer]:
		key.disabled()

func enable_all_keys():
	for key in key_container.get_children() as Array[HBoxContainer]:
		key.enabled()
