extends Control

@export var default_font: FontFile = preload("res://Fonts/DTM-Sans.otf")

@onready var title: Label = $Title
@onready var instructions: Node2D = $Instructions
@onready var confirm: Label = $Instructions/Confirm
@onready var cancel: Label = $Instructions/Cancel
@onready var fullscreen: Label = $Instructions/Fullscreen
@onready var quit: Label = $Instructions/Quit
@onready var hint: Label = $Instructions/Hint
@onready var options: Node2D = $Options
@onready var begin_game_option: Label = $Options/BeginGame
@onready var settings_option: Label = $Options/Settings
@onready var font: FontFile = Global.get_font(default_font)

func _ready():
	#var accept_action_events: Array[InputEvent] = InputMap.action_get_events("accept")
	#var cancel_action_events: Array[InputEvent] = InputMap.action_get_events("cancel")
	var accept_events_name: Array[StringName] = []
	var cancel_events_name: Array[StringName] = []
	var fullscreen_event: StringName = Global.translate_input(InputMap.action_get_events("fullscreen")[0].as_text().replace(" (Physical)", "").to_lower())
	var quit_event: StringName = Global.translate_input(InputMap.action_get_events("quit")[0].as_text().replace(" (Physical)", "").to_lower())
	
	for accept_action_event in InputMap.action_get_events("accept") as Array[InputEvent]:
		accept_events_name.append(Global.translate_input(accept_action_event.as_text().replace(" (Physical)", "").to_lower()))
	
	for cancel_action_event in InputMap.action_get_events("cancel") as Array[InputEvent]:
		cancel_events_name.append(Global.translate_input(cancel_action_event.as_text().replace(" (Physical)", "").to_lower()))
	
	title.add_theme_font_override("font", font)
	
	for category_node in [instructions, options] as Array[Node]:
		for label in category_node.get_children() as Array[Label]:
			label.add_theme_font_override("font", font)
	
	title.text = "--- "
	title.text += [
		"Instruction",
		"指示",
		"教示",
		"Arahan",
		"指示"
	][db.data.settings.language]
	title.text += " ---"
	confirm.text = [
		"[{first_accept_event} or {second_accept_event}] - Confirm".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[{first_accept_event} 或 {second_accept_event}] - 确定".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[{first_accept_event} 或 {second_accept_event}] - 確定".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[{first_accept_event} atau {second_accept_event}] - Memasti".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]}),
		"[{first_accept_event} もしくは {second_accept_event}] - 確定する".format({first_accept_event = accept_events_name[0], second_accept_event = accept_events_name[1]})
	][db.data.settings.language]
	cancel.text = [
		"[{first_cancel_event} or {second_cancel_event}] - Cancel".format({first_cancel_event = cancel_events_name[0], second_cancel_event = cancel_events_name[1]}),
		"[{first_cancel_event} 或 {second_cancel_event}] - 取消".format({first_cancel_event = cancel_events_name[0], second_cancel_event = cancel_events_name[1]}),
		"[{first_cancel_event} 或 {second_cancel_event}] - 罷免".format({first_cancel_event = cancel_events_name[0], second_cancel_event = cancel_events_name[1]}),
		"[{first_cancel_event} atau {second_cancel_event}] - Batal".format({first_cancel_event = cancel_events_name[0], second_cancel_event = cancel_events_name[1]}),
		"[{first_cancel_event} もしくは {second_cancel_event}] - キャンセルする".format({first_cancel_event = cancel_events_name[0], second_cancel_event = cancel_events_name[1]})
	][db.data.settings.language]
	fullscreen.text = "[{fullscreen_event}] - ".format({fullscreen_event=fullscreen_event})
	fullscreen.text += [
		"Fullscreen",
		"全屏",
		"滿屏",
		"Skrin penuh",
		"フルスクリーン"
	][db.data.settings.language]
	quit.text = [
		"[Hold {quit_event}] - Quit".format({quit_event=quit_event}),
		"[长按 {quit_event}] - 退出".format({quit_event=quit_event}),
		"[長按 {quit_event}] - 辍".format({quit_event=quit_event}),
		"[Tekan dan tahan {quit_event}] - Keluar".format({quit_event=quit_event}),
		"[{quit_event} を長押しする] - 辞める".format({quit_event=quit_event})
	][db.data.settings.language]
	hint.text = [
		"When HP is 0, you lose.",
		"当你的生命值归零时，游戏结束。",
		"當尔之生命值歸零時，遊戲終止。",
		"Apabila HP menjadi 0, Kamu kalah.",
		"エイチピーがゼロになったら、ゲームオーバーです。"
	][db.data.settings.language]
	begin_game_option.text = [
		"Begin Game",
		"开始游戏",
		"開始遊戲",
		"Mulakan Permainan",
		"ゲームを開始する"
	][db.data.settings.language]
	settings_option.text = [
		"Settings",
		"设置",
		"置",
		"Tetapan",
		"設定"
	][db.data.settings.language]
