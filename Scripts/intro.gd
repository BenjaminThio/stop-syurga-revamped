extends Control

@export var image_transition_time: float = 2.0
@export var image_invisible_time: float = 1.0
@export var label_reset_time: float = 2.5
@export var music_fade_out_time: float = 5

var storylines: Array[String] = [
	"Once upon a time, there was a guy called Yi Fan.",
	"Yi Fan was gay and he fell in love with his friend, Zen Thye...",
	"After some observation, Yi Fan found that Zen Thye was actually gay too and they get with each other very soon.",
	"But this happiness is short-lived.",
	"The world is cruel, the discrimination from the society made Zen Thye's mental break down.",
	"Although Yi Fan never cares how everyone judges his relationship with Zen Thye.",
	"But one day Yi Fan found that Zen Thye cheating on him.",
	"At first, Yi Fan was very upset but soon his hate out of love and he decided to take revenge on Zen Thye.",
	"So how is Yi Fan gonna overcome his rough fate?",
	"Noone knows, It seems like only time will give us the answer."
]

func _ready() -> void:
	var image: TextureRect = get_child(0)
	var label: RichTextLabel = get_child(1)
	var typing_sound_effect: AudioStreamPlayer = get_child(2)
	
	image.self_modulate.a = 0
	for storylineIndex in range(len(storylines)):
		image.texture = load("res://Sprites/Intro/intro{imageIndex}.png".format({"imageIndex": storylineIndex + 1}))
		create_tween().tween_property(image, "self_modulate:a", 1, image_transition_time)
		typing_sound_effect.play()
		for character in storylines[storylineIndex]:
			label.text += character
			await time.sleep(get_calculated_char_appear_gap_time())
		typing_sound_effect.stop()
		await time.sleep(image_invisible_time)
		create_tween().tween_property(image, "self_modulate:a", 0, image_transition_time)
		await time.sleep(label_reset_time)
		label.text = ""

func get_calculated_char_appear_gap_time() -> float:
	var char_counter: int = 0
	var background_music_length : float = get_child(3).stream.get_length()
	
	for storyline in storylines:
		char_counter += len(storyline)
	return (background_music_length - music_fade_out_time - ((image_invisible_time + label_reset_time) * storylines.size())) / char_counter
