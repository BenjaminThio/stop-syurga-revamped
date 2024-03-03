extends Node2D

var action_index: int = 0
var interactable: bool = false
var focus: bool = false
var confirmed_action: bool = false
var global_coroutine_id: int = 0
var damage_meter_scene: PackedScene = preload("res://Instances/damage_meter.tscn")
var menu_scene: PackedScene = preload("res://Instances/menu.tscn")
var description_container_packed_scene: PackedScene = preload("res://Instances/description_container.tscn")
var languages: PackedStringArray = [
	"default",
	"chinese",
	"chinese",
	"malay",
	"japanese"
]

@onready var description: String = [
	"The air is filled with the essence of freedom.",
	"空气中弥漫着自由的气息。",
	"乾坤之中充溢着自由之气。",
	"Udara dipenuhi dengan semangat kebebasan.",
	"空気は自由の息吹で満ちている。"
][db.data.settings.language]
@onready var description_manager: Node2D = get_tree().get_first_node_in_group("description_manager")
@onready var description_list_container: VBoxContainer = description_manager.get_node("ScrollContainer/DescriptionListContainer")
@onready var villain_health_bar: ProgressBar = description_manager.get_child(1)
@onready var typing_sound_effect: AudioStreamPlayer = description_manager.get_child(2)
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var battlefield: Control = get_tree().get_first_node_in_group("battlefield")

func _ready() -> void:
	for action in get_children():
		action.animation = languages[db.data.settings.language]
	
	if State.current_state == State.MAIN_STATE.TAKING_ACTION:
		description_manager.clear()
		take_action()

func _process(_delta) -> void:
	if State.current_state != State.MAIN_STATE.TAKING_ACTION or not interactable:
		return
	
	if ModifiedInput.either_of_the_actions_just_pressed(["left", "right"]) and not focus and not confirmed_action:
		get_child(action_index).frame = 0
		if Input.is_action_just_pressed("left"):
			if action_index - 1 >= 0:
				action_index -= 1
			elif action_index - 1 < 0:
				action_index = get_child_count() - 1
		elif Input.is_action_just_pressed("right"):
			if action_index + 1 < get_child_count():
				action_index += 1
			elif action_index + 1 <= get_child_count():
				action_index = 0
		update_player_position()
		get_child(action_index).frame = 1
		Audio.play_sound("squeak")
	elif Input.is_action_just_pressed("accept"):
		typing_sound_effect.stop()
		Audio.play_sound("select")
		if not focus:
			match action_index:
				State.MAIN_STATE.FIGHT, State.MAIN_STATE.ACT:
					focus = true
					focus_action()
				State.MAIN_STATE.ITEM, State.MAIN_STATE.MERCY:
					if action_index == State.MAIN_STATE.ITEM and PlayerData.items.size() == 0:
						return
					confirm_action()
		elif focus:
			confirm_action()
	elif Input.is_action_just_pressed("cancel"):
		if not focus and not confirmed_action:
			return
		elif confirmed_action:
			confirmed_action = false
		elif focus:
			focus = false
		
		if not description_manager.visible:
			description_manager.show()
		
		if focus:
			focus_action()
		elif not focus:
			unfocus_action()
		Audio.play_sound("squeak")

func take_action(required_transition: bool = false) -> void:
	interactable = false
	update_player_position()
	
	await battlefield.set_property(Vector2(768, 192), Vector2(192, 336), required_transition)
	
	description_manager.show()
	generate_description()
	get_child(action_index).frame = 1
	interactable = true

func focus_action() -> void:
	description_manager.clear()
	description_manager.generate_description("  * {villain_name}".format({"villain_name": villain.enemy_name.to_upper()}), false, false, false)
	
	match action_index:
		State.MAIN_STATE.FIGHT:
			var first_description_lines: Array[Node] = description_list_container.get_child(0).get_child(1).get_children()
			var description_width: float = 0
			
			for characters_container in first_description_lines:
				for character_label in characters_container.get_children():
					description_width += character_label.size.x
			
			villain_health_bar.position.x = description_width + 40
			villain_health_bar.max_value = villain.max_health
			villain_health_bar.value = villain.health
			villain_health_bar.show()
	
	if villain.spareable:
		description_manager.modulate = Color.YELLOW
	update_player_position()

func unfocus_action() -> void:
	description_manager.clear()
	description_manager.modulate = Color.WHITE
	if villain_health_bar.visible:
		villain_health_bar.hide()
	update_player_position()
	generate_description()

func confirm_action() -> void:
	confirmed_action = true
	description_manager.clear()
	description_manager.modulate = Color.WHITE
	if villain_health_bar.visible:
		villain_health_bar.hide()
	description_manager.hide()
	State.set_state(action_index)
	
	match State.current_state:
		State.MAIN_STATE.FIGHT:
			var damage_meter: Node2D = damage_meter_scene.instantiate()
			
			get_child(action_index).frame = 0
			canvas.add_child(damage_meter)
			damage_meter.slide_slider()
		State.MAIN_STATE.ACT, State.MAIN_STATE.ITEM, State.MAIN_STATE.MERCY:
			var menu: VBoxContainer = menu_scene.instantiate()
			
			battlefield.add_child(menu)
			
			await get_tree().process_frame
			
			if State.current_state == State.MAIN_STATE.MERCY and villain.spareable:
				menu.get_child(0).get_child(0).self_modulate = Color.YELLOW
			menu.update_player_position()

func generate_description(transition_time: float = 0.03) -> void:
	var description_container: HBoxContainer = description_container_packed_scene.instantiate()
	var font_width: int
	
	description_list_container.add_child(description_container)
	
	if db.data.settings.language in [db.LANGUAGE.CHINESE, db.LANGUAGE.CLASSICAL_CHINESE, db.LANGUAGE.JAPANESE]:
		font_width = description_manager.font_width
	else:
		font_width = 27
	
	global_coroutine_id += 1
	
	var local_coroutine_id: int = global_coroutine_id
	
	for description_character in "{description}".format({"description": Autowrap.smart_autowrap(description, font_width, description_list_container, 30)}):
		if not focus and not confirmed_action and local_coroutine_id == global_coroutine_id:
			description_container.text += description_character
			if not typing_sound_effect.playing and os.is_alpha(description_character):
				typing_sound_effect.play()
			elif typing_sound_effect.playing and not os.is_alpha(description_character):
				typing_sound_effect.stop()
			
			if description_character != "\n":
				await time.sleep(transition_time)
			else:
				continue
		else:
			return
	if typing_sound_effect.playing:
		typing_sound_effect.stop()

func update_player_position() -> void:
	if not focus:
		player.global_position = get_child(action_index).global_position
	elif focus:
		player.global_position = description_manager.global_position

func reset() -> void:
	interactable = false
	focus = false
	confirmed_action = false
