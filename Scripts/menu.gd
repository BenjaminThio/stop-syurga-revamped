extends VBoxContainer

@export var default_font: FontFile = preload("res://Fonts/DTM-Mono.otf")

var menu: CustomMenu
var player_coord: Vector2i = Vector2i.ZERO
var page_index: int = 0

@onready var action_buttons: Node2D = get_tree().get_first_node_in_group("actions")
@onready var health_bar: ProgressBar = get_tree().get_first_node_in_group("health_bar")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var description_manager: Node2D = get_tree().get_first_node_in_group("description_manager")

func _ready() -> void:
	update_font()
	menu = CustomMenu.new()
	
	if State.current_state == State.MAIN_STATE.ACT:
		menu.create_static_menu(action_buttons.get_child(action_buttons.action_index).translated_options, 2)
	elif State.current_state == State.MAIN_STATE.ITEM:
		if PlayerData.items.size() < 4:
			menu.create_paged_menu(PlayerData.items, PlayerData.items.size())
		elif PlayerData.items.size() >= 4:
			menu.create_paged_menu(PlayerData.items, 4)
	elif State.current_state == State.MAIN_STATE.MERCY:
		menu.create_static_menu(action_buttons.get_child(action_buttons.action_index).translated_options, 1)
	
	render_menu()

func _process(_delta) -> void:
	if State.current_state not in [State.MAIN_STATE.ACT, State.MAIN_STATE.ITEM, State.MAIN_STATE.MERCY]:
		return
		
	if ModifiedInput.either_of_the_actions_just_pressed(["up", "left", "down", "right"]):
		if Input.is_action_just_pressed("up"):
			move(move_up)
		elif Input.is_action_just_pressed("left"):
			move(move_left)
		elif Input.is_action_just_pressed("down"):
			move(move_down)
		elif Input.is_action_just_pressed("right"):
			move(move_right)
		Audio.play_sound("squeak")
		update_player_position()
		
		if menu.paged:
			render_menu()
		
	elif Input.is_action_just_pressed("cancel"):
		State.set_state(State.MAIN_STATE.TAKING_ACTION)
		queue_free()
		
	elif Input.is_action_just_pressed("accept"):
		if State.current_state in [State.MAIN_STATE.ACT, State.MAIN_STATE.MERCY]:
			var action_manager: Node = action_buttons.get_child(action_buttons.action_index)
			
			action_manager.select_option((player_coord.y * menu.width) + player_coord.x)
			
		elif State.current_state == State.MAIN_STATE.ITEM:
			var item: Item = menu.options[page_index][player_coord.y][player_coord.x]
			
			hide()
			player.hide()
			action_buttons.get_child(action_buttons.action_index).frame = 0
			action_buttons.reset()
			item.fulfill_effect(health_bar)
			PlayerData.items.pop_at((page_index * (menu.width * menu.height)) + (player_coord.y * menu.width) + player_coord.x)
			description_manager.upcoming_event = queue_free
			description_manager.set_statements([
				[
					[
						"You ate the {item_name}.".format({item_name = item.item_name}),
						"你吃了{item_name}。".format({item_name = item.item_name}),
						"尔食{item_name}。".format({item_name = item.item_name}),
						"Kamu telah makan {item_name}.".format({item_name = item.item_name}),
						"あなたは{item_name}を食べました。".format({item_name = item.item_name})
					][db.data.settings.language]
				]
			])
			if PlayerData.health < PlayerData.max_health:
				description_manager.statements[0].append([
					"You recovered {heal_value} HP!".format({heal_value = item.heal_value}),
					"你恢复了{heal_value}点生命值！".format({heal_value = item.heal_value}),
					"尔恢復矣{heal_value}點生命值！".format({heal_value = item.heal_value}),
					"Kamu telah memulihkan {heal_value} HP.".format({heal_value = item.heal_value}),
					"あなたは{heal_value}ポイントの体力を回復しました！".format({heal_value = item.heal_value})
				][db.data.settings.language])
			elif PlayerData.health == PlayerData.max_health:
				description_manager.statements[0].append([
					"Your HP was maxed out.",
					"你的生命值已满。",
					"尔之生命值已满。",
					"HP kamu telah penuh.",
					"あなたのエイチピーが満タンです。"
				][db.data.settings.language])
			Audio.play_sound("heal")
		
		Audio.play_sound("select")

func update_font():
	var font: FontFile = Global.get_font(default_font)
	
	for row in get_children():
		for option in row.get_children() as Array[RichTextLabel]:
			option.set("theme_override_fonts/normal_font", font)
			
			if db.data.settings.language in [db.LANGUAGE.ENGLISH, db.LANGUAGE.MALAY]:
				option.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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

func move(move_function: Callable) -> void:
	move_function.call()
			
	while is_option_null(player_coord):
		move_function.call()

func update_player_position() -> void:
	var act_label: RichTextLabel = get_child(player_coord.y).get_child(player_coord.x)
	
	player.global_position = Vector2(act_label.global_position.x - 50, act_label.global_position.y + (act_label.size.y / 2))

func render_menu() -> void:
	for row_index in range(menu.height):
		for option_index in range(menu.width):
			var option_label: RichTextLabel = get_child(row_index).get_child(option_index)
			
			if not is_option_null(Vector2i(option_index, row_index)):
				var option: String = get_option(Vector2i(option_index, row_index))
				
				option_label.text = "* {option}".format({"option": option.capitalize()})
			else:
				option_label.text = ""
			
	if menu.paged:
		var last_row: HBoxContainer = get_child(get_child_count() - 1)
		var page_label: RichTextLabel = last_row.get_child(last_row.get_child_count() - 1)
		
		#page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		page_label.text_direction = Control.TEXT_DIRECTION_RTL
		page_label.text = "PAGE {page_number}".format({"page_number": page_index + 1})

func is_option_null(option_coord: Vector2i) -> bool:
	var option
	var row_index: int = option_coord.y
	var option_index: int = option_coord.x
	
	if menu.paged:
		option = menu.options[page_index][row_index][option_index]
	else:
		option = menu.options[row_index][option_index]
	
	if option != null:
		return false
	return true

func get_option(option_coord: Vector2i):
	var row_index: int = option_coord.y
	var option_index: int = option_coord.x
	
	if menu.paged:
		return menu.options[page_index][row_index][option_index].item_name
	else:
		return menu.options[row_index][option_index]

func has_made_decision():
	player.hide()
	action_buttons.get_child(action_buttons.action_index).frame = 0
	action_buttons.reset()
	State.set_state(State.MAIN_STATE.COMBATING)
	queue_free()
