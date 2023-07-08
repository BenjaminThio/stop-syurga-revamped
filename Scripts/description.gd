extends RichTextLabel

var statements: Array = []:
	get:
		return statements
	set(value):
		if get_stack()[1].source == get_script().get_path():
			statements = value
			State.add_substate_to_queue(State.SUBSTATE.STATEMENT)
		else:
			Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var skipable: bool = false
var upcoming_event: Callable = Callable()

@onready var typing_sound_effect: AudioStreamPlayer = $AudioStreamPlayer
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")

func _ready():
	text = ""

func _process(_delta) -> void:
	if State.current_substate == State.SUBSTATE.STATEMENT:
		if Input.is_action_just_pressed("accept") and skipable:
			text = ""
			generate_statement()

func generate_statement() -> void:
	skipable = false
	if statements.size() > 0:
		if typeof(statements[0]) == TYPE_STRING:
			await generate_description(statements[0])
		elif typeof(statements[0]) == TYPE_ARRAY:
			await generate_descriptions(statements[0])
		statements.pop_front()
		skipable = true
	elif statements.size() == 0:
		State.substate_completed()
		if State.current_substate != null:
			State.complete_on_queue_substate()
		elif State.current_substate == null:
			if villian.health > 0:
				State.set_state(State.MAIN_STATE.COMBATING)
				if not upcoming_event.is_null():
					upcoming_event.call()
					upcoming_event = Callable()
			elif villian.health == 0:
				Transition.fade_in(canvas, func(): get_tree().change_scene_to_file("res://Scenes/main_manu.tscn"))

func generate_description(description, transition_time: float = 0.03) -> void:
	typing_sound_effect.play()
	for description_character in "* {description}".format({"description": description}):
		text += description_character
		await time.sleep(transition_time)
	typing_sound_effect.stop()

func generate_descriptions(descriptions, transition_time: float = 0.03) -> void:
	for description in descriptions:
		await generate_description(description, transition_time)
		text += "\n"

func set_statements(values: Array):
	for value in values:
		if typeof(value) not in [TYPE_STRING, TYPE_ARRAY]:
			Debug.log_error(Debug.ARGUMENT_TYPE_UNACCEPTABLE.format({"unacceptable_type": Debug.type_of(value), "acceptable_types": " / ".join([Debug.type_of(TYPE_STRING), Debug.type_of(TYPE_ARRAY)])}), true)
			return
	statements = values
