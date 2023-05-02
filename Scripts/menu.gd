extends VBoxContainer

var menu: CustomMenu
var player_coord: Coordinate = Coordinate.new()
var page_index: int = 0

@onready var action_buttons: Node2D = get_tree().get_first_node_in_group("actions")

func _ready() -> void:
	menu = CustomMenu.new()
	
	if State.current_state == State.ACT:
		menu.create_static_menu(action_buttons.get_child(action_buttons.action_index).get_child(0).OPTIONS, 2)
	elif State.current_state == State.ITEM:
		if db.items.size() < 4:
			menu.create_paged_menu(db.items, db.items.size())
		elif db.items.size() >= 4:
			menu.create_paged_menu(db.items, 4)
	elif State.current_state == State.MERCY:
		menu.create_static_menu(action_buttons.get_child(action_buttons.action_index).get_child(0).OPTIONS, 1)
	
	render_menu()

func _process(_delta) -> void:
	if State.current_state not in [State.ACT, State.ITEM, State.MERCY]:
		return
	
	if ModifiedInput.either_of_the_actions_just_pressed(["up", "left", "down", "right"]):
		if Input.is_action_just_pressed("up"):
			move_up()
			
			while get_option(player_coord.y, player_coord.x) == "":
				move_up()
		elif Input.is_action_just_pressed("left"):
			move_left()
			
			while get_option(player_coord.y, player_coord.x) == "":
				move_left()
		elif Input.is_action_just_pressed("down"):
			move_down()
			
			while get_option(player_coord.y, player_coord.x) == "":
				move_down()
		elif Input.is_action_just_pressed("right"):
			move_right()
			
			while get_option(player_coord.y, player_coord.x) == "":
				move_right()
		get_tree().get_root().get_node("Main").play_sound_effect("squeak")
		update_player_position()
		
		if menu.paged:
			render_menu()
		
	elif Input.is_action_just_pressed("cancel"):
		var description_label: Node = preload("res://Instances/description.tscn").instantiate()
		var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
		
		battlefield.add_child(description_label)
		State.change_state(State.TAKING_ACTION)
		queue_free()
	
	elif Input.is_action_just_pressed("accept"):
		var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
		
		if State.current_state in [State.ACT, State.MERCY]:
			var action_manager: Node = action_buttons.get_child(action_buttons.action_index).get_child(0)
			var option: String = get_option(player_coord.y, player_coord.x)
			
			action_manager.select_option(option)
		
		elif State.current_state == State.ITEM:
			var item: Item = menu.options[page_index][player_coord.y][player_coord.x]
			var health_bar: ProgressBar = get_tree().get_first_node_in_group("health_bar")
			
			item.fulfill_effect(health_bar)
		
		get_tree().get_root().get_node("Main").play_sound_effect("select")
		player.hide()
		action_buttons.turn_off()
		State.change_state(State.COMBATING)
		self.queue_free()

func move_up() -> void:
	if player_coord.y - 1 >= 0:
		player_coord.y -= 1
	else:
		player_coord.y = menu.height - 1

func move_left() -> void:
	if menu.paged and player_coord.x - 1 < 0:
		if page_index - 1 >= 0:
			page_index -= 1
		else:
			page_index = menu.options.size() - 1
	
	if player_coord.x - 1 >= 0:
		player_coord.x -= 1
	else:
		player_coord.x = menu.width - 1
		if not menu.paged:
			move_up()

func move_down() -> void:
	if player_coord.y + 1 < menu.height:
		player_coord.y += 1
	else:
		player_coord.y = 0

func move_right() -> void:
	if menu.paged and player_coord.x + 1 >= menu.width:
		if page_index + 1 < menu.options.size():
			page_index += 1
		else:
			page_index = 0
	
	if player_coord.x + 1 < menu.width:
		player_coord.x += 1
	else:
		player_coord.x = 0
		if not menu.paged:
			move_down()

func render_menu() -> void:
	for row_index in range(menu.height):
		for option_index in range(menu.width):
			var option_label: Label = get_child(row_index).get_child(option_index)
			var option: String = get_option(row_index, option_index)
			
			if option != "":
				option_label.text = "* {option}".format({"option": option.capitalize()})
			
	if menu.paged:
		var last_row: HBoxContainer = get_child(get_child_count() - 1)
		var page_label: Label = last_row.get_child(last_row.get_child_count() - 1)
		
		page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		page_label.text = "PAGE {page_number}".format({"page_number": page_index + 1})

func get_option(row_index: int, option_index: int) -> String:
	var option: String
	
	if menu.paged:
		option = menu.options[page_index][row_index][option_index].item_name
	else:
		option = menu.options[row_index][option_index]
	
	return option

func update_player_position() -> void:
	var act_label: Label = get_child(player_coord.y).get_child(player_coord.x)
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	
	player.global_position = Vector2(act_label.global_position.x - 50, act_label.global_position.y + (act_label.size.y / 2))