extends Node

enum INPUT_ACTION_TYPE {
	BOTH,
	BUILT_IN,
	NON_BUILT_IN
}
enum BUS_CHANNEL
{
	MASTER,
	BGM,
	SFX
}

const ACTUAL_LOWEST_VOLUME: int = -88
const PERCEIVED_LOWEST_VOLUME: int = -55
const PERCEIVED_HIGHEST_VOLUME: int = 0
const QUIT_DURATION: float = 1.0

var origin_scene: String = "res://Scenes/main_menu.tscn":
	get:
		var duplicated_origin_scene: String = origin_scene
		
		if origin_scene != "":
			origin_scene = ""
		return duplicated_origin_scene
var reset: bool = false
var quitting_label_scene: PackedScene = preload("res://Instances/quitting_label.tscn")
var has_encountered_villain: bool = false
var loop_attack_index = null
var towards_exit: bool = false
var input_listener_activated: bool = false
var input_translation: Dictionary = {
	up = [
		"up",
		"上",
		"上",
		"atas",
		"上"
	],
	left = [
		"left",
		"左",
		"左",
		"kiri",
		"左"
	],
	down = [
		"down",
		"下",
		"下",
		"bawah",
		"下"
	],
	right = [
		"right",
		"右",
		"右",
		"kanan",
		"右"
	],
	accept = [
		"confirm",
		"确定",
		"確定",
		"memasti",
		"確定する"
	],
	cancel = [
		"cancel",
		"取消",
		"罷免",
		"batal",
		"キャンセルする"
	],
	flashlight = [
		"flashlight",
		"手电筒",
		"手炬",
		"lampu suluh",
		"懐中電灯"
	],
	fullscreen = [
		"fullscreen",
		"全屏",
		"滿屏",
		"skrin penuh",
		"フルスクリーン"
	],
	quit = [
		"quit",
		"退出",
		"辍",
		"Keluar",
		"辞める"
	],
	cheat = [
		"cheat",
		"作弊",
		"作弊",
		"tipu",
		"チート"
	],
	jump = [
		"jump",
		"跳",
		"躍",
		"lompat",
		"跳ぶ"
	]
}

func _ready():
	update_audio_server()

#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif Input.is_action_just_pressed("quit") or Input.is_action_just_released("quit"):
		var tween: Tween = null
		
		if Input.is_action_just_pressed("quit") and not input_listener_activated:
			var loaded_scene: Node = get_tree().root.get_child(-1)
			var quitting_label: Label = quitting_label_scene.instantiate()
			var default_font: FontFile = quitting_label.get_theme_font("font")
			var full_stop: String = [
				".",
				"。",
				"。",
				".",
				"…"
			][db.data.settings.language]
			
			quitting_label.text = [
				"QUITTING",
				"退出中",
				"辍中",
				"KELUAR DARI PERMAINAN",
				"ゲームを辞める"
			][db.data.settings.language]
			quitting_label.add_theme_font_override("font", get_font(default_font))
			loaded_scene.add_child(quitting_label)
			tween = create_tween()
			tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).tween_property(quitting_label, "self_modulate:a", 1, QUIT_DURATION).finished.connect(get_tree().quit)
			await time.sleep(QUIT_DURATION / 2)
			if is_instance_valid(quitting_label):
				quitting_label.text += full_stop
		elif Input.is_action_just_released("quit"):
			var quitting_label: Label = get_tree().get_first_node_in_group("quitting_label")
			
			if tween != null:
				tween.kill()
				tween = null
			
			if is_instance_valid(quitting_label):
				quitting_label.queue_free()

func translate_input(input_name: String) -> String:
	"""
	input_name = input_name.to_lower()
	
	if input_name in input_translation:
		return input_translation[input_name][db.data.settings.language].to_upper() #capitalize()
	elif "+" in input_name:
		var translated_split_combos: Array[StringName] = []
		
		for split_combo in input_name.split("+") as PackedStringArray:
			if split_combo in input_translation:
				translated_split_combos.append(input_translation[split_combo][db.data.settings.language].to_upper())
			else:
				translated_split_combos.append(split_combo.to_upper())
		return "+".join(translated_split_combos)
	else:
		return input_name.to_upper()
	"""
	return input_name.to_upper()

func get_font(default_language: FontFile = null) -> FontFile:
	if db.data.settings.language in [db.LANGUAGE.CHINESE, db.LANGUAGE.CLASSICAL_CHINESE, db.LANGUAGE.JAPANESE]:
		return load("res://Fonts/fusion-pixel-12px-monospaced-zh_hans.otf")
	else:
		return default_language

func get_input_map_actions(input_action_type: INPUT_ACTION_TYPE = INPUT_ACTION_TYPE.NON_BUILT_IN) -> Array[StringName]:
	var all_actions: Array[StringName] = InputMap.get_actions()
	var actions: Array[StringName] = []
	
	if input_action_type == INPUT_ACTION_TYPE.BOTH:
		return all_actions
	
	for action in all_actions:
		if input_action_type == INPUT_ACTION_TYPE.BUILT_IN and action.begins_with("ui_") or input_action_type == INPUT_ACTION_TYPE.NON_BUILT_IN and not action.begins_with("ui_"):
			actions.append(action)
	
	return actions

func get_input_map() -> Dictionary:
	var input_map: Dictionary = {}
	
	for action_name in Global.get_input_map_actions(Global.INPUT_ACTION_TYPE.NON_BUILT_IN) as Array[StringName]:
		input_map[action_name] = InputMap.action_get_events(action_name)
	
	return input_map

func update_audio_server() -> void:
	for bus_channel in BUS_CHANNEL.values():
		var volume_fraction: float
		
		if bus_channel == BUS_CHANNEL.MASTER:
			volume_fraction = db.data.settings.master_volume
		elif bus_channel == BUS_CHANNEL.BGM:
			volume_fraction = db.data.settings.bgm_volume
		elif bus_channel == BUS_CHANNEL.SFX:
			volume_fraction = db.data.settings.sfx_volume
		
		AudioServer.set_bus_volume_db(bus_channel, get_value_in_range(PERCEIVED_LOWEST_VOLUME, PERCEIVED_HIGHEST_VOLUME, volume_fraction))
		
		if volume_fraction == 0:
			AudioServer.set_bus_volume_db(bus_channel, ACTUAL_LOWEST_VOLUME)

func get_value_in_range(initial_value: float, final_value: float, fraction: float) -> float:
	return ((final_value - initial_value) * fraction) + initial_value
