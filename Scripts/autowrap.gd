class_name Autowrap extends Node

const space: String = " "

static func smart_autowrap(text: String, font_width: int, container: Control, container_width_shrink: float = 0, required_autowrapped_text_optimization: bool = true) -> String:
	var split_space_text: PackedStringArray = text.split(" ")
	
	for word_index in range(split_space_text.size()):
		if word_index < split_space_text.size() - 1 and (split_space_text[word_index] + space).length() * font_width != container.size.x - abs(container_width_shrink):
			split_space_text[word_index] += space
	
	return get_smart_autowrap_text(split_space_text, font_width, container.size.x - abs(container_width_shrink), required_autowrapped_text_optimization)

static func get_smart_autowrap_text(split_space_text: PackedStringArray, font_width: int, container_width: float, required_autowrapped_text_optimization: bool) -> String:
	var line_width: int = 0
	var smart_autowrap_text: String = ""
	
	for word in split_space_text:
		var previous_line_width: int = line_width
		
		if "\n" in word:
			var split_line_break_text: PackedStringArray = word.split("\n")
			
			for sub_word_index in range(split_line_break_text.size()):
				var sub_word: String = split_line_break_text[sub_word_index]
				var sub_word_width: int = sub_word.length() * font_width
				
				if sub_word_width > container_width:
					for character in sub_word:
						line_width += font_width
						
						if line_width > container_width:
							smart_autowrap_text += "\n"
							line_width = font_width
						
						smart_autowrap_text += character
				else:
					line_width += sub_word_width
				
					if line_width > container_width:
						if previous_line_width + ((sub_word.replace(space, "")).length() * font_width) <= container_width:
							smart_autowrap_text += sub_word.replace(space, "")
							continue
						
						smart_autowrap_text += "\n"
						line_width = sub_word.length() * font_width
					
					smart_autowrap_text += sub_word
				
				if sub_word_index < split_line_break_text.size() - 1:
					smart_autowrap_text += "\n"
					line_width = 0
		else:
			var word_width: int = word.length() * font_width
			
			if word_width > container_width:
				for character in word:
					line_width += font_width
					
					if line_width > container_width:
						smart_autowrap_text += "\n"
						line_width = font_width
					
					smart_autowrap_text += character
			else:
				line_width += word_width
			
				if line_width > container_width:
					if previous_line_width + ((word.replace(space, "")).length() * font_width) <= container_width:
						smart_autowrap_text += word.replace(space, "")
						continue
					
					smart_autowrap_text += "\n"
					line_width = word.length() * font_width
				
				smart_autowrap_text += word
	
	if required_autowrapped_text_optimization:
		#print([optimize_autowrapped_text(smart_autowrap_text)])
		return optimize_autowrapped_text(smart_autowrap_text)
	else:
		#print([smart_autowrap_text])
		return smart_autowrap_text

#Strip sentence of each line's edges.
static func optimize_autowrapped_text(text: String) -> String:
	var optimized_lines: PackedStringArray = []
	
	for line in text.split("\n"):
		optimized_lines.append(line.strip_edges())
	
	return "\n".join(optimized_lines)

"""
enum FIX_FAILED_METHOD {
	NULL,
	SMART_PUSH,
	EXPAND_CONTAINER
}

	if is_word_width_greater_than_container_width(split_space_text, font_width, container.size.x - abs(container_width_shrink)):
		if fix_failed == FIX_FAILED_METHOD.EXPAND_CONTAINER:
			var longest_word_width: int = 0
			
			for word in split_space_text:
				var word_width: int = word.length() * font_width
				
				if word_width > longest_word_width:
					longest_word_width = word_width + abs(container_width_shrink)
				
			container.size.x = longest_word_width
			
			return get_smart_autowrap_text(split_space_text, font_width, container.size.x - abs(container_width_shrink), required_autowrapped_text_optimization)
		elif fix_failed == FIX_FAILED_METHOD.SMART_PUSH:
			return get_smart_autowrap_text(split_space_text, font_width, container.size.x - abs(container_width_shrink), required_autowrapped_text_optimization)
		else:
			#return text
			return "Autowrap failed due to a word exceeding the container width."

static func is_word_width_greater_than_container_width(split_space_text: PackedStringArray, font_width: int, container_width: float) -> bool:
	for word in split_space_text:
		var word_width: int = word.length() * font_width
		
		if word_width > container_width:
			return true
	return false
"""
