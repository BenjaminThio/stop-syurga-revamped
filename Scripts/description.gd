extends Node2D

@export var font_size: int = 27
@export var font_width: int = 16

var statements: Array = []:
	get:
		return statements
	set(value):
		#if get_stack()[1].source == get_script().get_path():
			statements = value
			State.add_substate_to_queue(State.SUBSTATE.STATEMENT)
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var description_container_packed_scene: PackedScene = preload("res://Instances/description_container.tscn")
var skipable: bool = false
var upcoming_event: Callable = Callable()
var is_transition_disabled: bool = false

@onready var typing_sound_effect: AudioStreamPlayer = $TypingSoundEffect
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var description_list_container: VBoxContainer = $ScrollContainer/DescriptionListContainer

func _ready():
	clear()

func _process(_delta) -> void:
	if State.current_substate == State.SUBSTATE.STATEMENT:
		if Input.is_action_just_pressed("accept") and skipable:
			clear()
			generate_statement()
		elif Input.is_action_just_pressed("cancel"):
			is_transition_disabled = true

func clear():
	ModifiedNode.clear_children(description_list_container)

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
			if villain.health > 0:
				State.set_state(State.MAIN_STATE.COMBATING)
				if not upcoming_event.is_null():
					upcoming_event.call()
					upcoming_event = Callable()
			elif villain.health == 0:
				Transition.fade_in(canvas, func():
					Global.towards_exit = true
					get_tree().change_scene_to_file("res://Scenes/encounter.tscn"))

func generate_description(description, required_star_sign: bool = true, required_transition: bool = true, required_autowrapped_text_optimization: bool = true, transition_time: float = 0.03) -> void:
	var description_container: HBoxContainer = description_container_packed_scene.instantiate()
	
	is_transition_disabled = false
	
	description_container.required_star_sign = required_star_sign
	description_list_container.add_child(description_container)
	typing_sound_effect.play()
	for description_character in "{description}".format({"description": Autowrap.smart_autowrap(description, font_width, description_list_container, -30, required_autowrapped_text_optimization)}):
		description_container.text += description_character
		
		if required_transition and description_character != "\n" and not is_transition_disabled:
			await time.sleep(transition_time)
		else:
			continue
		
	typing_sound_effect.stop()

func generate_descriptions(descriptions, required_star_sign: bool = true, required_transition: bool = true, transition_time: float = 0.03) -> void:
	for description in descriptions:
		await generate_description(description, required_star_sign, required_transition, transition_time)

func set_statements(values: Array):
	for value in values:
		if typeof(value) not in [TYPE_STRING, TYPE_ARRAY]:
			Debug.log_error(Debug.ARGUMENT_TYPE_UNACCEPTABLE.format({"unacceptable_type": Debug.type_of(value), "acceptable_types": " / ".join([Debug.type_of(TYPE_STRING), Debug.type_of(TYPE_ARRAY)])}), true)
			return
	statements = values
