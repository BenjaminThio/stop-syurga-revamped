extends Node2D

var action_index: int = 0
var interactable: bool = false
var focus: bool = false
var confirmed_action: bool = false
var global_coroutine_id: int = 0
var damage_meter_scene: PackedScene = preload("res://Instances/damage_meter.tscn")
var menu_scene: PackedScene = preload("res://Instances/menu.tscn")

@onready var description: String = [
	"The air is filled with the essence of freedom.",
	"空气中弥漫着自由的气息。",
	"乾坤之中充溢着自由之气。",
	"Udara dipenuhi dengan semangat kebebasan.",
	"空気は自由の息吹で満ちている。"
][db.data.settings.language]
@onready var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
@onready var villian_health_bar: ProgressBar = description_label.get_child(0)
@onready var typing_sound_effect: AudioStreamPlayer = description_label.get_child(1)
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var battlefield: Control = get_tree().get_first_node_in_group("battlefield")

func _ready() -> void:
	if State.current_state == State.MAIN_STATE.TAKING_ACTION:
		description_label.text = ""
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
		
		if not description_label.visible:
			description_label.show()
		
		if focus:
			focus_action()
		elif not focus:
			unfocus_action()
		Audio.play_sound("squeak")

func take_action(required_transition: bool = false) -> void:
	interactable = false
	update_player_position()
	
	await battlefield.set_property(Vector2(768, 192), Vector2(192, 336), required_transition)
	
	description_label.show()
	generate_description()
	get_child(action_index).frame = 1
	interactable = true

func focus_action() -> void:
	description_label.text = "\t* {villian_name}".format({"villian_name": villian.enemy_name.to_upper()})
	
	match action_index:
		State.MAIN_STATE.FIGHT:
			villian_health_bar.position.x = description_label.get_content_width() + 40
			villian_health_bar.max_value = villian.max_health
			villian_health_bar.value = villian.health
			villian_health_bar.show()
	
	if villian.spareable:
		description_label.self_modulate = Color.YELLOW
	update_player_position()

func unfocus_action() -> void:
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	if villian_health_bar.visible:
		villian_health_bar.hide()
	update_player_position()
	generate_description()

func confirm_action() -> void:
	confirmed_action = true
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	if villian_health_bar.visible:
		villian_health_bar.hide()
	description_label.hide()
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
			await time.sleep(0.001)
			if State.current_state == State.MAIN_STATE.MERCY and villian.spareable:
				menu.get_child(0).get_child(0).self_modulate = Color.YELLOW
			menu.update_player_position()

func generate_description(transition_time: float = 0.03) -> void:
	global_coroutine_id += 1
	
	var local_coroutine_id: int = global_coroutine_id
	
	for description_character in "* {description}".format({"description": description}):
		if not focus and not confirmed_action and local_coroutine_id == global_coroutine_id:
			description_label.text += description_character
			if not typing_sound_effect.playing and os.is_alpha(description_character):
				typing_sound_effect.play()
			elif typing_sound_effect.playing and not os.is_alpha(description_character):
				typing_sound_effect.stop()
			await time.sleep(transition_time)
		else:
			return
	if typing_sound_effect.playing:
		typing_sound_effect.stop()

func update_player_position() -> void:
	if not focus:
		player.global_position = get_child(action_index).global_position
	elif focus:
		player.global_position = Vector2(description_label.global_position.x + description_label.pivot_offset.x, description_label.global_position.y + description_label.pivot_offset.y)

func reset() -> void:
	interactable = false
	focus = false
	confirmed_action = false
