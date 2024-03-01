extends ScrollContainer

var row_container_packed_scene: PackedScene = preload("res://Instances/input_map_row_container.tscn")

@onready var column_container = $ColumnContainer

func _ready():
	update_input_map()

func update_input_map():
	clear_input_map()
	
	for action_name in Global.get_input_map_actions(Global.INPUT_ACTION_TYPE.NON_BUILT_IN) as Array[StringName]:
		var row_container: HBoxContainer = row_container_packed_scene.instantiate()
		var input_events: Array[InputEvent] = InputMap.action_get_events(action_name)
		
		column_container.add_child(row_container)
		row_container.action = action_name
		row_container.input_events = input_events

func clear_input_map():
	ModifiedNode.clear_children(column_container)

func is_any_action_contains_event(event: InputEvent) -> bool:
	for action_name in Global.get_input_map_actions(Global.INPUT_ACTION_TYPE.NON_BUILT_IN) as Array[StringName]:
		if InputMap.action_has_event(action_name, event):
			return true
	return false

func disable_all_keys():
	for input_map_row_container in column_container.get_children() as Array[HBoxContainer]:
		input_map_row_container.disable_all_keys()

func enable_all_keys():
	for input_map_row_container in column_container.get_children() as Array[HBoxContainer]:
		input_map_row_container.enable_all_keys()

func set_input_listener_activated(is_activated: bool):
	Global.input_listener_activated = is_activated
	
	if is_activated:
		disable_all_keys()
	else:
		enable_all_keys()

func update_language():
	for input_map_row_container in column_container.get_children() as Array[HBoxContainer]:
		input_map_row_container.update_action_label_by_language()
