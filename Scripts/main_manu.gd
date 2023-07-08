extends Control

enum OPTION {
	CONTINUE,
	RESET,
	SETTINGS,
	LEADERBOARD,
	CREDITS,
	QUIT
}
var selected_option: int = 0

@onready var name_label: Label = $Name
@onready var level_label: Label = $Level
@onready var location_name_label: Label = $Location/Name
@onready var location_description_label: Label = $Location/Description
@onready var decoration_sign: Label = $Location/DecorationSign
@onready var playtime: Label = $Playtime
@onready var options: Node2D = $Options
@onready var continue_label: Label = $Options/Continue
@onready var reset_label: Label = $Options/Reset
@onready var settings_label: Label = $Options/Settings
@onready var leaderboard_label: Label = $Options/Leaderboard
@onready var credits_label: Label = $Options/Credits
@onready var quit_label: Label = $Options/Quit

func _ready():
	continue_label.text = [
		"Continue",
		"继续游戏",
		"续玩",
		"Teruskan", #"Teruskan Permainan",
		"ゲームを続ける"
	][db.data.settings.language]
	reset_label.text = [
		"Reset",
		"重置",
		"复位",
		"Menetap Semula",
		"リセットする"
	][db.data.settings.language]
	settings_label.text = [
		"Settings",
		"设置",
		"置",
		"Tetapan",
		"設定"
	][db.data.settings.language]
	leaderboard_label.text = [
		"Leaderboard",
		"排行榜",
		"序列",
		"Papan Kedudukan",
		"ランキング"
	][db.data.settings.language]
	credits_label.text = [
		"Credits",
		"制作人员名单",
		"製作人員表",
		"Kredit",
		"クレジット"
	][db.data.settings.language]
	quit_label.text = [
		"Quit",
		"退出游戏",
		"離場",
		"Keluar", #"Keluar Dari Permainan",
		"ゲームを辞める"
	][db.data.settings.language]
	
	name_label.text = db.data.player.name
	level_label.text = [
		"LV {level}".format({"level": db.get_player_level()}),
		"{level} 级".format({"level": db.get_player_level()}),
		"{level} 品".format({"level": db.get_player_level()}),
		"TAHAP {level}".format({"level": db.get_player_level()}),
		"{level} レベル".format({"level": db.get_player_level()})
	][db.data.settings.language]
	location_name_label.text = [
		["Void"],
		["虚空"],
		["虚无"],
		["Kosong"],
		["虚無"]
	][db.data.settings.language][db.data.player.location_index]
	location_description_label.text = [
		["Darkness"],
		["黑暗"],
		["冥暗"],
		["Kegelapan"],
		["アンダーク"]
	][db.data.settings.language][db.data.player.location_index]
	playtime.text = ("%.2f" % (db.data.player.playtime / 60.0)).replace(".", ":")
	highlight_selected_option()

func _process(_delta):
	if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]):
		if Input.is_action_just_pressed("up"):
			if selected_option - 1 >= 0:
				selected_option -= 1
			elif selected_option - 1 < 0:
				selected_option = options.get_child_count() - 1
		elif Input.is_action_just_pressed("down"):
			if selected_option + 1 < options.get_child_count():
				selected_option += 1
			elif selected_option + 1 >= options.get_child_count():
				selected_option = 0
		remove_highlight()
		highlight_selected_option()
	elif Input.is_action_just_pressed("accept"):
		if selected_option == OPTION.CONTINUE:
			get_tree().change_scene_to_file("res://Scenes/encounter.tscn")
		elif selected_option == OPTION.RESET or selected_option == OPTION.SETTINGS:
			Global.origin_scene = get_tree().current_scene.scene_file_path
			if selected_option == OPTION.RESET:
				Global.reset = true
				get_tree().change_scene_to_file("res://Scenes/new_game.tscn")
			elif selected_option == OPTION.SETTINGS:
				get_tree().change_scene_to_file("res://Scenes/settings.tscn")
		elif selected_option == OPTION.LEADERBOARD:
			return
		elif selected_option == OPTION.CREDITS:
			get_tree().change_scene_to_file("res://Scenes/credits.tscn")
		elif selected_option == OPTION.QUIT:
			get_tree().quit()

func remove_highlight():
	for option in options.get_children():
		option.set("theme_override_colors/font_color", Color.WHITE)

func highlight_selected_option():
	var option: Label = options.get_child(selected_option)
	
	option.set("theme_override_colors/font_color", Color.YELLOW)

func _on_location_name_label_resized():
	decoration_sign.position.x = location_name_label.position.x + location_name_label.size.x
	location_description_label.position.x = decoration_sign.position.x + decoration_sign.size.x
