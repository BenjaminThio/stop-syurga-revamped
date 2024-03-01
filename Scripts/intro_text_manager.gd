#@tool
extends VBoxContainer

@export var default_font: FontFile = preload("res://Fonts/DTM-Mono.otf")
@export var font_size: int = 30

@onready var font: FontFile = Global.get_font(default_font)

#@export
var text: String = "":
	set(value):
		text = value
		update_text()
	get:
		return text

func _ready():
	update_text()

func update_text():
	if get_child_count() > 0:
		ModifiedNode.clear_children(self)
	
	#print([text])
	for character in text:
		var new_char: Label = Label.new()
		
		if get_child_count() == 0:
			create_new_char_container()
		
		if character == "\n":
			create_new_char_container()
		else:
			new_char.text = character
			new_char.add_theme_font_override("font", font)
			new_char.add_theme_font_size_override("font_size", font_size)
			get_child(-1).add_child(new_char)

func create_new_char_container(separation: int = 0) -> void:
	var char_container: HBoxContainer = HBoxContainer.new()
	
	char_container.add_theme_constant_override("separation", separation)
	add_child(char_container)
