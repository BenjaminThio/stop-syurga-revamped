extends Control

@export var default_font: FontFile = preload("res://Fonts/DTM-Mono.otf")

@onready var title: Label = $VerticalContainer/Title
@onready var exit_chars: HBoxContainer = $ExitChars
@onready var font: FontFile = Global.get_font(default_font)

func _ready():
	title.add_theme_font_override("font", font)
	title.text = [
		"Please choose an attack.",
		"请选择一种攻击方式。",
		"擇一種攻擊之法。",
		"Sila pilih satu kaedah serangan.",
		"攻撃方法を選択してください。"
	][db.data.settings.language]
	var exit_text: String = [
		"Exit",
		"退出",
		"辍",
		"Keluar",
		"辞める"
	][db.data.settings.language]
	
	ModifiedNode.clear_children(exit_chars)
	for exit_char in exit_text:
		var new_label: Label = Label.new()
		
		new_label.text = exit_char
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_label.uppercase = true
		new_label.custom_minimum_size.x = 20
		new_label.add_theme_color_override("font_color", Color.WHITE)
		new_label.add_theme_font_override("font", font)
		new_label.add_theme_font_size_override("font_size", 36)
		
		exit_chars.add_child(new_label)
