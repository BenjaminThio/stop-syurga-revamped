extends Node2D

var action_index: int = 0
var description: String = "You can feel the freedom." #"The air is filled with the breath of freedom."
var interactable: bool = false
var focus: bool = false
var confirmed_action: bool = false
var global_coroutine_id: int = 0
var damage_meter_scene: PackedScene = preload("res://Instances/damage_meter.tscn")
var menu_scene: PackedScene = preload("res://Instances/menu.tscn")

@onready var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var battlefield: Control = get_tree().get_first_node_in_group("battlefield")

func _ready() -> void:
	if State.current_state == State.TAKING_ACTION:
		description_label.text = ""
		take_action()

func _process(_delta):
	if State.current_state != State.TAKING_ACTION or not interactable:
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
		owner.play_sound_effect("squeak")
	elif Input.is_action_just_pressed("accept"):
		if not focus:
			match action_index:
				State.FIGHT, State.ACT, State.MERCY:
					focus = true
					focus_action()
				State.ITEM:
					confirm_action()
		elif focus:
			confirm_action()
		owner.play_sound_effect("select")
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
		owner.play_sound_effect("squeak")

func take_action(required_transition: bool = false):
	interactable = false
	update_player_position()
	
	await battlefield.set_property(Vector2(768, 192), Vector2(192, 336), required_transition)
	
	description_label.show()
	generate_description()
	get_child(action_index).frame = 1
	interactable = true

func focus_action():
	description_label.text = "\t* {villian_name}".format({"villian_name": villian.enemy_name})
	description_label.self_modulate = Color.YELLOW
	update_player_position()

func confirm_action():
	confirmed_action = true
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	description_label.hide()
	State.change_state(action_index)
	match State.current_state:
		State.FIGHT:
			var damage_meter: Node2D = damage_meter_scene.instantiate()
			
			canvas.add_child(damage_meter)
			damage_meter.slide_slider()
		State.ACT, State.ITEM, State.MERCY:
			var menu: VBoxContainer = menu_scene.instantiate()
			
			battlefield.add_child(menu)
			await time.sleep(0.001)
			menu.update_player_position()

func unfocus_action():
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	update_player_position()
	generate_description()

func generate_description() -> void:
	global_coroutine_id += 1
	
	var local_coroutine_id: int = global_coroutine_id
	
	for description_character in "* {description}".format({"description": description}):
		if not focus and local_coroutine_id == global_coroutine_id:
			description_label.text += description_character
			await time.sleep(0.03)
		else:
			break

func update_player_position() -> void:
	if not focus:
		player.global_position = get_child(action_index).global_position
	elif focus:
		player.global_position = Vector2(description_label.global_position.x + description_label.pivot_offset.x, description_label.global_position.y + description_label.pivot_offset.y)

func reset():
	interactable = false
	action_index = 0
	focus = false
	confirmed_action = false

"""
@onready var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
@onready var typing_sound_effect: AudioStreamPlayer = description_label.get_child(0)
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	for action in get_children():
		actions.append(action.name.to_lower())
	
	take_action()

func _process(_delta) -> void:
	if State.current_state != State.TAKING_ACTION:
		return
	if ModifiedInput.either_of_the_actions_just_pressed(["left", "right"]) and not focus:
		if Input.is_action_just_pressed("left"):
			if action_index - 1 >= 0:
				action_index -= 1
			else:
				action_index = get_child_count() - 1
		elif Input.is_action_just_pressed("right"):
			if action_index + 1 < get_child_count():
				action_index += 1
			else:
				action_index = 0
		owner.play_sound_effect("squeak")
		update_player_position()
	elif Input.is_action_just_pressed("accept"):
		description_label.text += "a"
		if not focus:
			match actions[action_index]:
				State.ITEM:
					if db.items.size() > 0:
						confirm_action()
				State.FIGHT, State.ACT, State.MERCY:
					owner.play_sound_effect("select")
					focus_action()
			description_label.show()
		elif focus:
			confirm_action()
	elif Input.is_action_just_pressed("cancel"):
		description_label.show()
		owner.play_sound_effect("squeak")
		if focus or confirmed_action:
			if focus and confirmed_action:
				focus_action()
				confirmed_action = false
				return
			elif focus and not confirmed_action:
				focus = false
			elif not focus and confirmed_action:
				confirmed_action = false
			update_player_position()
			generate_description()

func confirm_action() -> void:
	description_label.hide()
	owner.play_sound_effect("select")
	State.change_state(actions[action_index])
	confirmed_action = true
	match State.current_state:
		State.FIGHT:
			var damage_meter: Node = preload("res://Instances/damage_meter.tscn").instantiate()
			
			canvas.add_child(damage_meter)
			damage_meter.slide_slider()
		State.ACT, State.ITEM, State.MERCY:
			var menu: Node = preload("res://Instances/menu.tscn").instantiate()
			
			battlefield.add_child(menu)
			await time.sleep(0.001)
			menu.update_player_position()

func focus_action() -> void:
	focus = true
	typing_sound_effect.stop()
	description_label.text = "\t* {villian_name}".format({"villian_name": get_tree().get_first_node_in_group("villian").get_child(0).name})
	player.global_position = Vector2(description_label.global_position.x + description_label.pivot_offset.x, description_label.global_position.y + description_label.pivot_offset.y)
	description_label.self_modulate = Color.YELLOW

func take_action(required_transition: bool = false) -> void:
	update_player_position()
	
	await battlefield.set_property(Vector2(768, 192), Vector2(192, 336), required_transition)
	
	description_label.show()
	generate_description()

func generate_description() -> void:
	current_coroutine_id += 1
	var coroutine_id: int = current_coroutine_id
	
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	if not focus:
		typing_sound_effect.play()
	
	for character in "* {description}".format({"description": description}):
		if not focus and not confirmed_action and coroutine_id == current_coroutine_id:
			description_label.text += character
		else:
			return
		await time.sleep(0.03)
	typing_sound_effect.stop()

func update_player_position() -> void:
	player.global_position = get_child(action_index).global_position
	turn_off()
	get_child(action_index).frame = 1

func turn_off() -> void:
	for action_button in get_children():
		action_button.frame = 0

func reset() -> void:
	action_index = 0
	focus = false
	confirmed_action = false
"""
