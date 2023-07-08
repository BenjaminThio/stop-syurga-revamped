extends Control

@onready var instruction: Label = $Title/TitleText
@onready var instruction1_keys: Label = $Instructions/Instruction1/Keys
@onready var instruction1_description: Label = $Instructions/Instruction1/Description
@onready var instruction2_keys: Label = $Instructions/Instruction2/Keys
@onready var instruction2_description: Label = $Instructions/Instruction2/Description
@onready var instruction3_keys: Label = $Instructions/Instruction3/Keys
@onready var instruction3_description1: Label = $Instructions/Instruction3/Description/DescriptionText1
@onready var instruction3_description_linking_char: Label = $Instructions/Instruction3/Description/LinkingChar
@onready var instruction3_description2: Label = $Instructions/Instruction3/Description/DescriptionText2
@onready var instruction4_description: Label = $Instructions/Instruction4/Description
@onready var instruction5_key: Label = $Instructions/Instruction5/Key
@onready var instruction5_description: Label = $Instructions/Instruction5/Description
@onready var instruction6: Label = $Instructions/Instruction6
@onready var begin_game_option: Label = $Options/BeginGame
@onready var settings_option: Label = $Options/Settings

func _ready():
	instruction.text = [
		"Instruction",
		"指示",
		"教示",
		"Arahan",
		"指示"
	][db.data.settings.language]
	instruction1_keys.text = [
		"[Z or ENTER]",
		"[Z 或 ENTER]",
		"[Z 或 ENTER]",
		"[Z atau ENTER]",
		"[Z もしくは ENTER]"
	][db.data.settings.language]
	instruction1_description.text = [
		"Confirm",
		"确定",
		"確定",
		"Memasti",
		"確定する"
	][db.data.settings.language]
	"""
	instruction1_description.text = [
		"Confirm",
		"确认",
		"證實",
		"Mengesah",
		"確認する"
	][db.data.settings.language]
	"""
	instruction2_keys.text = [
		"[X or SHIFT]",
		"[X 或 SHIFT]",
		"[X 或 SHIFT]",
		"[X atau SHIFT]",
		"[X もしくは SHIFT]"
	][db.data.settings.language]
	instruction2_description.text = [
		"Cancel",
		"取消",
		"罷免",
		"Batal",
		"キャンセルする"
	][db.data.settings.language]
	instruction3_keys.text = [
		"[C or CTRL]",
		"[C 或 CTRL]",
		"[C 或 CTRL]",
		"[C atau CTRL]",
		"[C もしくは CTRL]"
	][db.data.settings.language]
	instruction3_description1.text = [
		"Menu (In",
		"菜单 (游戏中)",
		"菜單 (遊戲之中)",
		"Menu (Dalam permainan)",
		"メニュー (ゲーム中)"
	][db.data.settings.language]
	if db.data.settings.language == db.LANGUAGE.ENGLISH:
		instruction3_description_linking_char.show()
		instruction3_description2.show()
	else:
		instruction3_description_linking_char.hide()
		instruction3_description2.hide()
	instruction4_description.text = [
		"Fullscreen",
		"全屏",
		"滿屏",
		"Skrin penuh",
		"フルスクリーン"
	][db.data.settings.language]
	instruction5_key.text = [
		"[Hold ESC]",
		"[长按 ESC]",
		"[長按 ESC]",
		"[Tekan dan tahan ESC]",
		"[ESC を長押しする]"
	][db.data.settings.language]
	instruction5_description.text = [
		"Quit",
		"退出",
		"辍",
		"Keluar",
		"辞める"
	][db.data.settings.language]
	instruction6.text = [
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
