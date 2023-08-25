extends Node2D

const TRANSLATED_QUIT: PackedStringArray = [
	"Quit",
	"退出",
	"辍",
	"Keluar",
	"辞める"
]
const TRANSLATED_BACKSPACE: PackedStringArray = [
	"Backspace",
	"退格键",
	"復歸鍵",
	"Tombol Kembali",
	"バックスペース",
]
const TRANSLATED_DONE: PackedStringArray = [
	"Done",
	"完成",
	"畢",
	"Selesai",
	"完了"
]
const translated_no: PackedStringArray = [
	"No",
	"不是",
	"否",
	"Bukan",
	"いいえ"
]
const translated_yes: PackedStringArray = [
	"Yes",
	"是的",
	"是",
	"Ya",
	"はい"
]

var keyboard_coord: Vector2i = Vector2i.ZERO
var is_keys_shaking: bool = false
var focus_name: bool = false
var is_name_shaking: bool = false
var confirmed_name: bool = false

@onready var main: Node2D = get_tree().get_root().get_node("NewGame")
@onready var background_music_player: AudioStreamPlayer = main.get_node("BackgroundMusic")
@onready var title_label: Label = owner.get_node("Title")
@onready var name_label: Label = owner.get_node("Name/NameLabel")
@onready var name_animation_player: AnimationPlayer = owner.get_node("Name/AnimationPlayer")
@onready var cymbal_sound_effect: AudioStreamPlayer = owner.get_node("CymbalSoundEffect")
@onready var break_option: Label = get_child(-1).get_child(0)
@onready var backspace_option: Label = get_child(-1).get_child(1)
@onready var continue_option: Label = get_child(-1).get_child(2)

func _ready():
	var keyboard: Array[Node] = get_children()
	
	name_label.text = main.name_label_text
	keyboard_coord = main.keyboard_coord
	keyboard.pop_back()
	update_keyboard()
	update_keyboard_keys()
	
	await time.sleep(0.001)
	
	for keyboard_row in keyboard:
		for key in keyboard_row.get_children():
			loop_shake_by_position(key)

func _process(_delta):
	if focus_name:
		shake_name()
	
	if confirmed_name:
		return
	
	if not focus_name:
		if ModifiedInput.either_of_the_actions_just_pressed(["up", "left", "down", "right"]):
			if Input.is_action_just_pressed("up"):
				if keyboard_coord.y - 1 >= 0:
					if keyboard_coord.y == get_child_count() - 1:
						keyboard_coord.x *= get_child(get_child_count() - 1).get_child_count()
						if keyboard_coord.x - 1 > 0:
							keyboard_coord.x -= 1
					keyboard_coord.y -= 1
					while keyboard_coord.x >= get_child(keyboard_coord.y).get_child_count():
						keyboard_coord.y -= 1
				elif keyboard_coord.y - 1 < 0:
					keyboard_coord.y = get_child_count() - 1
					@warning_ignore("integer_division")
					keyboard_coord.x = floor((keyboard_coord.x + 1) / get_child(get_child_count() - 1).get_child_count())
			elif Input.is_action_just_pressed("left"):
				if keyboard_coord.x - 1 >= 0:
					keyboard_coord.x -= 1
				elif keyboard_coord.x - 1 < 0:
					if keyboard_coord.y == get_child_count() - 1:
						keyboard_coord.x = get_child(keyboard_coord.y).get_child_count() - 1
					elif keyboard_coord.y - 1 >= 0:
						keyboard_coord.y -= 1
						keyboard_coord.x = get_child(keyboard_coord.y).get_child_count() - 1
			elif Input.is_action_just_pressed("down"):
				if keyboard_coord.y + 1 < get_child_count():
					keyboard_coord.y += 1
					while keyboard_coord.x >= get_child(keyboard_coord.y).get_child_count():
						if keyboard_coord.y == get_child_count() - 1:
							break
						elif keyboard_coord.y < get_child_count() - 1:
							keyboard_coord.y += 1
					if keyboard_coord.y == get_child_count() - 1:
						@warning_ignore("integer_division")
						keyboard_coord.x = floor((keyboard_coord.x + 1) / get_child(get_child_count() - 1).get_child_count())
				elif keyboard_coord.y + 1 >= get_child_count():
					if keyboard_coord.y == get_child_count() - 1:
						keyboard_coord.x *= get_child(get_child_count() - 1).get_child_count()
						if keyboard_coord.x - 1 > 0:
							keyboard_coord.x -= 1
					keyboard_coord.y = 0
			elif Input.is_action_just_pressed("right"):
				if keyboard_coord.x + 1 < get_child(keyboard_coord.y).get_child_count():
					keyboard_coord.x += 1
				elif keyboard_coord.x + 1 >= get_child(keyboard_coord.y).get_child_count():
					if keyboard_coord.y == get_child_count() - 1 or keyboard_coord.y + 1 < get_child_count() - 1:
						keyboard_coord.x = 0
					if keyboard_coord.y + 1 < get_child_count() - 1:
						keyboard_coord.y += 1
			reset_keyboard()
			update_keyboard_keys()
		elif Input.is_action_just_pressed("accept"):
			var selected_key: String = get_child(keyboard_coord.y).get_child(keyboard_coord.x).text.strip_edges()
			
			if selected_key in TRANSLATED_QUIT:
				main.name_label_text = name_label.text
				main.keyboard_coord = keyboard_coord
				
				if Global.reset:
					Global.reset = false
					get_tree().change_scene_to_file(Global.origin_scene)
				else:
					main.activate_scene(main.SCENE.INSTRUCTION)
			elif selected_key in TRANSLATED_BACKSPACE:
				backspace()
			elif selected_key in TRANSLATED_DONE:
				if name_label.text.length() >= PlayerData.min_name_length:
					focus_name = true
					keyboard_coord.x = 0
					keyboard_coord.y = get_child_count() - 1
					reset_keyboard()
					update_keyboard_keys()
					update_keyboard()
				else:
					return
			elif name_label.text.length() + 1 <= PlayerData.max_name_length:
				name_label.text += selected_key
			elif name_label.text.length() + 1 > PlayerData.max_name_length:
				backspace()
				name_label.text += selected_key
		elif Input.is_action_just_pressed("cancel"):
			backspace()
	elif focus_name:
		if ModifiedInput.either_of_the_actions_just_pressed(["left", "right"]):
			if Input.is_action_just_pressed("left"):
				if keyboard_coord.x - 2 >= 0:
					keyboard_coord.x -= 2
				elif keyboard_coord.x - 1 < 0:
					keyboard_coord.x = get_child(-1).get_child_count() - 1
			elif Input.is_action_just_pressed("right"):
				if keyboard_coord.x + 2 < get_child(-1).get_child_count():
					keyboard_coord.x += 2
				elif keyboard_coord.x + 1 >= get_child(-1).get_child_count():
					keyboard_coord.x = 0
			reset_keyboard()
			update_keyboard_keys()
		elif Input.is_action_just_pressed("accept"):
			var selected_option: String = get_child(keyboard_coord.y).get_child(keyboard_coord.x).text.strip_edges()
			
			if selected_option in translated_no:
				focus_name = false
				keyboard_coord.y = get_child_count() - 1
				keyboard_coord.x = get_child(-1).get_child_count() - 1
				reset_keyboard()
				update_keyboard_keys()
				update_keyboard()
			elif selected_option in translated_yes:
				var cymbal_sound_effect_length: float = cymbal_sound_effect.stream.get_length()
				
				confirmed_name = true
				db.data.player.name = name_label.text
				db.save_data()
				background_music_player.stop()
				title_label.hide()
				get_child(-1).hide()
				cymbal_sound_effect.play()
				Transition.fade_in(
					owner,
					func() -> void: get_tree().change_scene_to_file("res://Scenes/encounter.tscn"),
					cymbal_sound_effect_length,
					Color.WHITE
				)

func shake_name():
	if not is_name_shaking:
		is_name_shaking = true
		await shake_by_position(name_label)
		await shake_by_rotation(name_label)
		is_name_shaking = false

func update_keyboard():
	var keyboard_rows: Array[Node] = get_children()
	
	keyboard_rows.pop_back()
	for keyboard_row in keyboard_rows:
		if focus_name:
			keyboard_row.hide()
		else:
			keyboard_row.show()
	
	if focus_name:
		title_label.text = [
			"Is this name correct?",
			"这个名字对吗？",
			"此名是否正確？",
			"Nama ini betulkah?",
			"この名前は正しいですか？"
		][db.data.settings.language]
		break_option.text = "    " + translated_no[db.data.settings.language]
		backspace_option.text = ""
		continue_option.text = "       " + translated_yes[db.data.settings.language]
		
		name_animation_player.play("zoom_in")
	else:
		title_label.text = [
			"Name yourself.",
			"请给自己取个名字。",
			"為自己命名。",
			"Beri nama kepada diri anda.",
			"自分に名前をつける。"
		][db.data.settings.language]
		break_option.text = TRANSLATED_QUIT[db.data.settings.language]
		backspace_option.text = TRANSLATED_BACKSPACE[db.data.settings.language]
		continue_option.text = "   " + TRANSLATED_DONE[db.data.settings.language]
		
		name_animation_player.stop()

func backspace():
	if name_label.text.length() - 1 >= 0:
		name_label.text = name_label.text.left(name_label.text.length() - 1)

func update_keyboard_keys():
	var selected_key: Label = get_child(keyboard_coord.y).get_child(keyboard_coord.x)
	
	selected_key.set("theme_override_colors/font_color", Color.YELLOW)

func reset_keyboard():
	for keyboard_row in get_children():
		for key in keyboard_row.get_children():
			key.set("theme_override_colors/font_color", Color.WHITE)

func shake_by_position(target: Label, offset_value: float = 0.5, delay_time: float = 0.03) -> void:
	var target_origin: Vector2 = target.position
	
	target.position = Vector2(target_origin.x + generate_random_shake_offset(offset_value), target_origin.y + generate_random_shake_offset(offset_value))
	await time.sleep(delay_time)
	target.position = target_origin

func shake_by_rotation(target: Label, offset_value: float = 0.7, delay_time: float = 0.03):
	target.rotation_degrees = generate_random_shake_offset(offset_value)
	await time.sleep(delay_time)
	target.rotation_degrees = 0

func loop_shake_by_position(target: Label, offset_value: float = 0.5, delay_time: float = 0.03) -> void:
	await shake_by_position(target, offset_value, delay_time)
	loop_shake_by_position(target, offset_value, delay_time)

func loop_shake_by_rotation(target: Label, offset_value: float = 0.7, delay_time: float = 0.03):
	await shake_by_rotation(target, offset_value, delay_time)
	loop_shake_by_rotation(target, offset_value, delay_time)

func generate_random_shake_offset(offset_value: float) -> float:
	var offset_values: PackedFloat32Array = [-offset_value, offset_value]
	
	return random.choice(offset_values)
