extends Node2D

const space: String = " "

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

func _ready():
	#Now the only challenge is to get every single character width. For now, I just set it as 16 as default due to the size of the label with font at a specific size - 27(Hard-coded).
	var smart_autowrap_text: String = get_smart_autowrap_text("Hi, my name is Benjamin Thio. Today I am going to tell you guys I am a gay!", 16, color_rect, true)
	
	#print([smart_autowrap_text])
	label.text = smart_autowrap_text

#Fix failed also known as auto expand.
func get_smart_autowrap_text(text: String, font_width: int, container: Control, fix_failed: bool = false) -> String:
	var split_space_text: PackedStringArray = text.split(" ")
	
	for word_index in range(split_space_text.size()):
		if word_index < split_space_text.size() - 1 and (split_space_text[word_index] + space).length() * font_width <= container.size.x:
			split_space_text[word_index] += space
	
	if is_word_width_greater_than_container_width(split_space_text, font_width, container.size.x):
		if fix_failed:
			var longest_word_width: int = 0
			
			for word in split_space_text:
				var word_width: int = word.length() * font_width
				
				if word_width > longest_word_width:
					longest_word_width = word_width
				
			container.size.x = longest_word_width
			
			return smart_autowrap(split_space_text, font_width, container.size.x)
		else:
			#return text
			return "Autowrap failed due to a word exceeding the container width."
	else:
		return smart_autowrap(split_space_text, font_width, container.size.x)

func smart_autowrap(split_space_text: PackedStringArray, font_width: int, container_width: float) -> String:
	var line_width: int = 0
	var smart_autowrap_text: String = ""
	
	for word in split_space_text:
		var previous_line_width: int = line_width
		var word_width: int = word.length() * font_width
		
		line_width += word_width
		
		if line_width > container_width:
			if previous_line_width + ((word.replace(space, "")).length() * font_width) <= container_width:
				smart_autowrap_text += word.replace(space, "")
				continue
			
			smart_autowrap_text += "\n"
			line_width = word.length() * font_width
		
		smart_autowrap_text += word
	
	return smart_autowrap_text

func is_word_width_greater_than_container_width(split_space_text: PackedStringArray, font_width: int, container_width: float) -> bool:
	for word in split_space_text:
		var word_width: int = word.length() * font_width
		
		if word_width > container_width:
			return true
	return false
