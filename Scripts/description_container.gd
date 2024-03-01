#@tool
extends HBoxContainer

@export var default_font: FontFile = preload("res://Fonts/DTM-Mono.otf")
@export var required_star_sign: bool = true
#@export
var text: String = "":
	set(value):
		text = value
		update_text()
	get:
		return text

@onready var star_sign: RichTextLabel = $StarSign
@onready var line_container: VBoxContainer = $LineContainer
@onready var font_size: int = get_parent().get_parent().get_parent().font_size
@onready var font: FontFile = Global.get_font(default_font)

func _ready():
	update_star_sign()
	update_text()

func update_star_sign():
	star_sign.add_theme_font_override("normal_font", font)
	
	if required_star_sign:
		star_sign.text = "*"
	else:
		star_sign.text = ""

func update_text():
	if line_container.get_child_count() > 0:
		ModifiedNode.clear_children(line_container)
	
	for character in text:
		var new_char: Label = Label.new()
		
		if line_container.get_child_count() == 0:
			create_new_char_container()
		
		if character == "\n":
			create_new_char_container()
		else:
			new_char.text = character
			new_char.add_theme_font_override("font", font)
			new_char.add_theme_font_size_override("font_size", font_size)
			line_container.get_child(-1).add_child(new_char)

func create_new_char_container(h_separation: int = 0) -> void:
	var char_container: HFlowContainer = HFlowContainer.new()
	
	char_container.add_theme_constant_override("h_separation", h_separation)
	line_container.add_child(char_container)

"""
	if char_container.get_child_count() > 0:
		char_container.get_child(0).self_modulate = Color.RED
"""
