extends Node2D

enum OPTION {
	EXIT,
	LANGUAGE
}
@export var sun_rotate_speed: int = 25
@export var default_font: FontFile = preload("res://Fonts/DTM-Sans.otf")

var selected_option: int = 0
var transition_finished: bool = false
var font: FontFile

@onready var exit_label: Label = $Exit
@onready var language_title_label: Label = $Language
@onready var language_label: Label = $Language/Language
@onready var title_label: Label = owner.get_node("Title")
@onready var snowflakes: Node2D = owner.get_node("Snowflakes")
@onready var sun_origin: Node2D = owner.get_node("SunOrigin")
@onready var leaves: Node2D = owner.get_node("Leaves")
@onready var withered_leaves: Node2D = owner.get_node("WitheredLeaves")
@onready var sun: Node2D = sun_origin.get_node("Sun")
@onready var background_music_player: AudioStreamPlayer = owner.get_node("BackgroundMusicPlayer")
@onready var blocking_mask: Control = owner.get_node("BlockingMask")
@onready var audio_system: Node2D = owner.get_node("AudioSystem")
@onready var master_label: Label = audio_system.get_node("Master")
@onready var bgm_label: Label = audio_system.get_node("Bgm")
@onready var sfx_label: Label = audio_system.get_node("Sfx")
@onready var input_map: ScrollContainer = owner.get_node("InputMap")

func _ready():
	#var harp_noise_length: float = Audio.play_sound_and_return_length("harpnoise")
	var date: Dictionary = Time.get_date_dict_from_system()
	
	highlight_selected_option()
	update_language()
	delay_update_input_settings_language()
	
	if date.month >= Time.MONTH_MARCH and date.month <= Time.MONTH_MAY:
		leaves.show()
	elif date.month >= Time.MONTH_SEPTEMBER and date.month <= Time.MONTH_NOVEMBER:
		withered_leaves.show()
	elif date.month >= Time.MONTH_JUNE and date.month <= Time.MONTH_AUGUST:
		sun_origin.show()
	elif date.month == Time.MONTH_DECEMBER or date.month >= Time.MONTH_JANUARY and date.month <= Time.MONTH_FEBRUARY:
		snowflakes.show()
	
	Audio.play_sound("harpnoise")
	await Transition.curtain_open(owner, 
		func():
			transition_finished = true
			audio_system.set_interactable(true)
			blocking_mask.hide()
	)
	
	if date.month >= Time.MONTH_MARCH and date.month <= Time.MONTH_MAY or date.month >= Time.MONTH_SEPTEMBER and date.month <= Time.MONTH_NOVEMBER:
		background_music_player.stream = load("res://Musics/mus_fall_spring.ogg")
	elif date.month >= Time.MONTH_JUNE and date.month <= Time.MONTH_AUGUST:
		background_music_player.stream = load("res://Musics/mus_summer.ogg")
	elif date.month == Time.MONTH_DECEMBER or date.month >= Time.MONTH_JANUARY and date.month <= Time.MONTH_FEBRUARY:
		background_music_player.stream = load("res://Musics/mus_winter.ogg")
	background_music_player.play()
	#background_music_player.finished.connect(get_tree().quit)
	
	#languages_showcase()

func _process(delta):
	if sun_origin.rotation_degrees < 360:
		sun_origin.rotation_degrees += PI * delta * sun_rotate_speed
	else:
		sun_origin.rotation_degrees = 0
	
	if sun_origin.rotation_degrees > -360:
		sun.rotation_degrees -= PI * delta * sun_rotate_speed
	else:
		sun.rotation_degrees = 0
	
	if not transition_finished or Global.input_listener_activated:
		return
	
	if ModifiedInput.either_of_the_actions_just_pressed(["up", "down"]):
		if Input.is_action_just_pressed("up") and selected_option - 1 >= 0:
			selected_option -= 1
		if Input.is_action_just_pressed("down") and selected_option + 1 < get_child_count():
			selected_option += 1
		reset_all_options_color()
		highlight_selected_option()
	elif ModifiedInput.either_of_the_actions_just_pressed(["accept", "left", "right"]):
		if Input.is_action_just_pressed("accept"):
			if selected_option == OPTION.EXIT:
				get_tree().change_scene_to_file(Global.origin_scene)
			elif selected_option == OPTION.LANGUAGE:
				language_right()
		elif selected_option == OPTION.LANGUAGE:
			if Input.is_action_just_pressed("left"):
				language_left()
			elif Input.is_action_just_pressed("right"):
				language_right()
		db.save_data()
		update_language()
		input_map.update_language()

func update_font():
	var font_variation: FontVariation = FontVariation.new()
	
	font = Global.get_font(default_font)
	
	font_variation.base_font = font
	font_variation.spacing_glyph = 1
	
	title_label.add_theme_font_override("font", font_variation)
	
	for label in [exit_label, language_title_label, language_label, master_label, bgm_label, sfx_label] as Array[Label]:
		label.add_theme_font_override("font", font)

func language_left():
	if db.data.settings.language - 1 >= 0:
		db.data.settings.language -= 1
	elif db.data.settings.language - 1 < 0:
		db.data.settings.language = db.LANGUAGE.size() - 1

func language_right():
	if db.data.settings.language + 1 < db.LANGUAGE.size():
		db.data.settings.language += 1
	elif db.data.settings.language + 1 >= db.LANGUAGE.size():
		db.data.settings.language = 0

func update_language():
	language_label.text = [
		"English",
		"华语",
		"文言文",
		"Melayu",
		"にほんご"
	][db.data.settings.language]
	exit_label.text = [
		"Exit",
		"退出",
		"辍",
		"Keluar",
		"辞める"
	][db.data.settings.language]
	title_label.text = [
		"Settings",
		"设置",
		"置",
		"Tetapan",
		"設定"
	][db.data.settings.language]
	language_title_label.text = [
		"Language",
		"语言",
		"語言",
		"Bahasa",
		"言語"
	][db.data.settings.language]
	master_label.text = [
		"Main",
		"主音",
		"主音",
		"Utama",
		"主要"
	][db.data.settings.language]
	bgm_label.text = [
		"Music",
		"音乐",
		"雅樂",
		"Muzik",
		"音楽"
	][db.data.settings.language]
	sfx_label.text = [
		"Sound",
		"音效",
		"音效",
		"Efek", # Bunyi",
		"音效"
	][db.data.settings.language]
	update_font()

func delay_update_input_settings_language():
	await get_tree().process_frame
	
	input_map.update_language()

func reset_all_options_color():
	for option_label in get_children():
		option_label.set("theme_override_colors/font_color", Color.WHITE)
		if option_label.get_child_count() > 0:
			for child in option_label.get_children():
				child.set("theme_override_colors/font_color", Color.WHITE)

func highlight_selected_option():
	var selected_option_label: Label = get_child(selected_option)
	
	selected_option_label.set("theme_override_colors/font_color", Color.YELLOW)
	if selected_option_label.get_child_count() > 0:
		for child in selected_option_label.get_children():
			child.set("theme_override_colors/font_color", Color.YELLOW)

func languages_showcase():
	await time.sleep(2.0)
	
	language_right()
	update_language()
	input_map.update_language()
	languages_showcase()
