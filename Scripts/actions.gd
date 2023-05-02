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
	
	var description_label: Node = preload("res://Instances/description.tscn").instantiate()
	get_tree().get_first_node_in_group("battlefield").add_child(description_label)
	
	update_player_position()
	
	generate_description()

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
			owner.play_sound_effect("select")
			focus_action()
		elif focus:
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
	elif Input.is_action_just_pressed("cancel") and focus:
		owner.play_sound_effect("squeak")
		if confirmed_action:
			focus_action()
			confirmed_action = false
		else:
			focus = false
			update_player_position()
			generate_description()

func focus_action() -> void:
	var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
	var typing_sound_effect: AudioStreamPlayer = description_label.get_child(0)
	
	focus = true
	typing_sound_effect.stop()
	description_label.text = "\t* {villian_name}".format({"villian_name": get_tree().get_first_node_in_group("villian").get_child(0).name})
	get_tree().get_first_node_in_group("player").global_position = Vector2(description_label.global_position.x + description_label.pivot_offset.x, description_label.global_position.y + description_label.pivot_offset.y)
	description_label.self_modulate = Color.YELLOW

func generate_description() -> void:
	var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
	var typing_sound_effect: AudioStreamPlayer = description_label.get_child(0)
	
	current_coroutine_id += 1
	var coroutine_id: int = current_coroutine_id
	
	description_label.text = ""
	description_label.self_modulate = Color.WHITE
	typing_sound_effect.play()
	
	for character in "* {description}".format({"description": description}):
		if not focus and coroutine_id == current_coroutine_id:
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
