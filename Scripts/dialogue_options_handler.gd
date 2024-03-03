extends VBoxContainer

enum OPTION {
	CONTINUE,
	GO_BACK
}

@export var default_font: FontFile = preload("res://Fonts/DTM-Mono.otf")
@export var pause_duration: float = 0.5

var selected_option: OPTION = OPTION.CONTINUE
var activate_after_dialogues: bool = false
var is_activated: bool = false
var is_transition_playing: bool = false

@onready var horizontal_container: HBoxContainer = $HorizontalContainer
@onready var soul: Sprite2D = owner.get_node("Soul")
@onready var canvas: Control = owner.get_node("Canvas")
@onready var dialogue: NinePatchRect = canvas.get_node("Dialogue")
@onready var unknown_sound_effect: AudioStreamPlayer = dialogue.get_node("SoundPlayer")
@onready var star_sign: RichTextLabel = dialogue.get_node("ScrollContainer/HorizontalContainer/StarSign")
@onready var continue_translation: String = [
	"Continue",
	"继续",
	"續",
	"Teruskan",
	"続ける"
][db.data.settings.language]
@onready var go_back_translation: String = [
	"Go Back",
	"回去",
	"歸返",
	"Pulang",
	"戻る"
][db.data.settings.language]
@onready var options: Array[String] = [
	continue_translation,
	go_back_translation
]

func _ready():
	clean_options()
	update_font()
	early_update_options_width()

func update_font():
	var font: FontFile = Global.get_font(default_font)
	
	for option in horizontal_container.get_children() as Array[Label]:
		option.add_theme_font_override("font", font)

func early_update_options_width():
	for option_index in range(options.size()) as Array[int]:
		var option: Label = horizontal_container.get_child(option_index)
		var font_width: int
		
		if db.data.settings.language in [db.LANGUAGE.CHINESE, db.LANGUAGE.CLASSICAL_CHINESE, db.LANGUAGE.JAPANESE]:
			font_width = option.get_theme_font_size("font_size")
		else:
			font_width = 20
		
		option.custom_minimum_size.x = options[option_index].length() * font_width

func _process(_delta):
	if activate_after_dialogues and not dialogue.on_queue:
		activate_after_dialogues = false
		dialogue.on_queue = true
		is_activated = true
		dialogue.show()
		star_sign.hide()
		show()
		await render_options(true)
		
		await get_tree().process_frame
		
		update_soul()
		update_selection()
	
	if not is_activated or is_transition_playing:
		return
	
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		if Input.is_action_just_pressed("left"):
			if selected_option - 1 >= 0:
				@warning_ignore("int_as_enum_without_cast")
				selected_option -= 1
			else:
				@warning_ignore("int_as_enum_without_cast")
				selected_option = OPTION.size() - 1
		elif Input.is_action_just_pressed("right"):
			if selected_option + 1 <= OPTION.size() - 1:
				@warning_ignore("int_as_enum_without_cast")
				selected_option += 1
			else:
				selected_option = OPTION.CONTINUE
		
		update_soul()
		update_selection()
		Audio.play_sound("squeak")
	if Input.is_action_just_pressed("accept"):
		if selected_option == OPTION.CONTINUE:
			is_activated = false
			reset_selection()
			update_soul()
			hide()
			star_sign.show()
			dialogue.work()
		elif selected_option == OPTION.GO_BACK:
			Transition.fade_in(canvas, func() -> void: get_tree().change_scene_to_file("res://Scenes/main_menu.tscn"))
			
		Audio.play_sound("select")

func render_options(required_transition: bool = false, transition_duration: float = 0.05):
	for option_index in range(options.size()) as Array[int]:
		var option: Label = horizontal_container.get_child(option_index)
		
		if required_transition:
			is_transition_playing = true
			unknown_sound_effect.play()
			
			for character in options[option_index]:
				option.text += character
				
				await time.sleep(transition_duration)
			
			unknown_sound_effect.stop()
			
			await time.sleep(pause_duration)
			
			is_transition_playing = false
		else:
			option.text = options[option_index]

func update_soul():
	if is_activated:
		soul.show()
		soul.scale = Vector2.ONE
		soul.self_modulate = Color.RED
	else:
		soul.hide()
		soul.global_position = Vector2(576, 448)
		soul.scale = Vector2(5, 5)
		soul.self_modulate = dialogue.battlefield_player_color

func update_selection():
	var option: Label = horizontal_container.get_child(selected_option)
	
	soul.global_position = Vector2(option.global_position.x - 30, option.global_position.y + (option.size.y / 2))

func reset_selection():
	selected_option = OPTION.CONTINUE

func clean_options():
	for option in horizontal_container.get_children() as Array[Label]:
		option.text = ""
