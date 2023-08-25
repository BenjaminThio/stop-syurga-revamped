extends Node

enum MAIN_STATE {
	FIGHT,
	ACT,
	ITEM,
	MERCY,
	IDLE,
	TAKING_ACTION,
	COMBATING,
	FLEE,
	REWARD,
	GAME_OVER
}
enum SUBSTATE {
	STATEMENT,
	SPEECH,
	SPARE
}
var current_state: MAIN_STATE = MAIN_STATE.IDLE:
	get:
		return current_state
	set(value):
		#if get_stack()[1].source == get_script().get_path():
			current_state = value
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE + "Please use \"set_state()\" function instead to change the current state.", true)
var substates_queue: Array[SUBSTATE] = []:
	get:
		return substates_queue
	set(value):
		#if get_stack()[1].source == get_script().get_path():
			substates_queue = value
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var current_substate:
	get:
		if substates_queue.size() > 0:
			return substates_queue[0]
		else:
			return null
	set(_value):
		pass
var states_stackable: bool = false:
	get:
		return states_stackable
	set(value):
		#if get_stack()[1].source == get_script().get_path():
			states_stackable = value
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var is_substate_busy: bool = false:
	get:
		return is_substate_busy
	set(value):
		#if get_stack()[1].source == get_script().get_path():
			is_substate_busy = value
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)

func set_state(new_state: MAIN_STATE) -> void:
	if new_state < MAIN_STATE.keys().size() and new_state != current_state:
		current_state = new_state
		if current_state == MAIN_STATE.COMBATING:
			var villian: Area2D = get_tree().get_first_node_in_group("villian")
			
			villian.cast_attack()
		elif current_state == MAIN_STATE.FLEE:
			var menu: VBoxContainer = get_tree().get_first_node_in_group("menu")
			var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
			var descriptions: PackedStringArray = ["Escaped...", "I've got better to do.", "I'm outta here."]
			
			menu.queue_free()
			description_label.text = "\t* {random_description}".format({"random_description": random.choice(descriptions)})
			description_label.show()

func add_substate_to_queue(substate: SUBSTATE):
	if substate != current_substate:
		substates_queue.append(substate)
		if not is_substate_busy:
			is_substate_busy = true
			complete_on_queue_substate()

func complete_on_queue_substate():
	if not states_stackable:
		current_state = MAIN_STATE.IDLE
	
	match current_substate:
		SUBSTATE.STATEMENT:
			var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
			
			description_label.visible = true
			description_label.generate_statement()
		SUBSTATE.SPEECH:
			var speech: Node2D = get_tree().get_first_node_in_group("speech")
			
			speech.visible = true
			speech.generate_speech()

func substate_completed(substate_index: int = 0):
	substates_queue.pop_at(substate_index)
	is_substate_busy = false

func set_states_stackable(stackable: bool):
	states_stackable = stackable
