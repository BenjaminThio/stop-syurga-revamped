extends Node2D

enum OPTION {
	EXIT,
	LANGUAGE
}
var selected_option: int = 0
var transition_finished: bool = false

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

@export var sun_rotate_speed: int = 25

func _ready():
	#var harp_noise_length: float = Audio.play_sound_and_return_length("harpnoise")
	var date: Dictionary = Time.get_date_dict_from_system()
	
	highlight_selected_option()
	update_language()
	
	if date.month >= Time.MONTH_MARCH and date.month <= Time.MONTH_MAY:
		leaves.show()
	elif date.month >= Time.MONTH_SEPTEMBER and date.month <= Time.MONTH_NOVEMBER:
		withered_leaves.show()
	elif date.month >= Time.MONTH_JUNE and date.month <= Time.MONTH_AUGUST:
		sun_origin.show()
	elif date.month == Time.MONTH_DECEMBER or date.month >= Time.MONTH_JANUARY and date.month <= Time.MONTH_FEBRUARY:
		snowflakes.show()
	
	Audio.play_sound("harpnoise")
	await Transition.curtain_open(owner, func(): transition_finished = true)
	
	if date.month >= Time.MONTH_MARCH and date.month <= Time.MONTH_MAY or date.month >= Time.MONTH_SEPTEMBER and date.month <= Time.MONTH_NOVEMBER:
		background_music_player.stream = load("res://Musics/mus_fall_spring.ogg")
	elif date.month >= Time.MONTH_JUNE and date.month <= Time.MONTH_AUGUST:
		background_music_player.stream = load("res://Musics/mus_summer.ogg")
	elif date.month == Time.MONTH_DECEMBER or date.month >= Time.MONTH_JANUARY and date.month <= Time.MONTH_FEBRUARY:
		background_music_player.stream = load("res://Musics/mus_winter.ogg")
	background_music_player.play()

func _process(delta):
	if sun_origin.rotation_degrees < 360:
		sun_origin.rotation_degrees += PI * delta * sun_rotate_speed
	else:
		sun_origin.rotation_degrees = 0
	
	if sun_origin.rotation_degrees > -360:
		sun.rotation_degrees -= PI * delta * sun_rotate_speed
	else:
		sun.rotation_degrees = 0
	
	if not transition_finished:
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
		elif Input.is_action_just_pressed("left"):
			language_left()
		elif Input.is_action_just_pressed("right"):
			language_right()
		db.save_data()
		update_language()

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
