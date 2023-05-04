extends Node2D

var action_index: int = 0
var description: String = "You can feel the freedom." #"The air is filled with the breath of freedom."
var focus: bool = false
var confirmed_action: bool = false
var current_coroutine_id: int = 0
@warning_ignore("shadowed_variable")
var actions: Array[String] = []

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
		if not focus:
			match actions[action_index]:
				State.ITEM:
					if db.items.size() > 0:
						confirm_action()
				State.FIGHT, State.ACT, State.MERCY:
					owner.play_sound_effect("select")
					focus_action()
		elif focus:
			confirm_action()
	elif Input.is_action_just_pressed("cancel"):
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
	owner.play_sound_effect("select")
	State.change_state(actions[action_index])
	confirmed_action = true
	match State.current_state:
		State.FIGHT:
			var damage_meter: Node = preload("res://Instances/damage_meter.tscn").instantiate()
			var canvas: Control = get_tree().get_first_node_in_group("canvas")
			
			canvas.add_child(damage_meter)
			damage_meter.slide_slider()
		State.ACT, State.ITEM, State.MERCY:
			var menu: Node = preload("res://Instances/menu.tscn").instantiate()
			var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
			
			battlefield.add_child(menu)
			await time.sleep(0.001)
			menu.update_player_position()
	
	var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
	
	description_label.queue_free()

func focus_action() -> void:
	var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
	var typing_sound_effect: AudioStreamPlayer = description_label.get_child(0)
	
	focus = true
	typing_sound_effect.stop()
	description_label.text = "\t* {villian_name}".format({"villian_name": get_tree().get_first_node_in_group("villian").get_child(0).name})
	get_tree().get_first_node_in_group("player").global_position = Vector2(description_label.global_position.x + description_label.pivot_offset.x, description_label.global_position.y + description_label.pivot_offset.y)
	description_label.self_modulate = Color.YELLOW

func take_action(required_transition: bool = false) -> void:
	if get_tree().get_first_node_in_group("description_label") == null:
		var description_label: Node = preload("res://Instances/description.tscn").instantiate()
	
		get_tree().get_first_node_in_group("battlefield").add_child(description_label)
	
	update_player_position()
	
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	
	await battlefield.set_property(Vector2(768, 192), Vector2(192, 336), required_transition)
	
	generate_description()

func generate_description() -> void:
	var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
	var typing_sound_effect: AudioStreamPlayer = description_label.get_child(0)
	
	current_coroutine_id += 1
	var coroutine_id: int = current_coroutine_id
	
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	typing_sound_effect.play()
	
	for character in "* {description}".format({"description": description}):
		if not focus and not confirmed_action and coroutine_id == current_coroutine_id:
			description_label.text += character
		else:
			return
		await time.sleep(0.03)
	typing_sound_effect.stop()

func update_player_position() -> void:
	get_tree().get_first_node_in_group("player").global_position = get_child(action_index).global_position
	turn_off()
	get_child(action_index).frame = 1

func turn_off() -> void:
	for action_button in get_children():
		action_button.frame = 0

func reset() -> void:
	action_index = 0
	focus = false
	confirmed_action = false
