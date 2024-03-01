extends Control

enum DIRECTION {
	NULL,
	HORIZONTAL,
	VERTICAL,
	BOTH
}

var next_line: bool = false

@onready var bubble: NinePatchRect = $Bubble
@onready var label: Label = $Label
@onready var test: Label = $Test
@onready var label_original_size: Vector2 = label.size

func _ready():
	generate_speech("blah blah blah blah blah!")

var words: PackedStringArray

func generate_speech(content: String):
	words = content.split(" ")
	
	for word_index in range(len(words) - 1):
		words[word_index] += " "
	
	generate_words()
	
	for word in words:
		for character in word:
			test.text += character
			await time.sleep(0.1)

func generate_words():
	for word_index in range(words.size()):
		for character in words[word_index]:
			label.text += character
			await time.sleep(pow(10, -21))
			if next_line:
				next_line = false
				words[word_index - 1] += "\n"
				label.text = ""
				generate_words()
				return

func _on_label_resized():
	var resized_direction: DIRECTION = DIRECTION.NULL
	
	if label.size.x > label_original_size.x or label.size.y > label_original_size.y:
		if label.size.x > label_original_size.x:
			next_line = true
			resized_direction = DIRECTION.HORIZONTAL
		if label.size.y > label_original_size.y:
			if resized_direction == DIRECTION.HORIZONTAL:
				resized_direction = DIRECTION.BOTH
			elif resized_direction != DIRECTION.HORIZONTAL:
				resized_direction = DIRECTION.VERTICAL
		#print(DIRECTION.keys()[resized_direction].capitalize())

func _on_test_resized():
	bubble.size += test.size - label_original_size
	label_original_size = test.size
