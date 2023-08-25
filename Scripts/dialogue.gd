extends NinePatchRect

var stacked_dialogues: PackedStringArray = []
var dialogue_index: int = 0
var on_queue: bool = false
var skipable: bool = false
var unknown: bool = true:
	get:
		return unknown
	set(is_unknown):
		unknown = is_unknown
		update_dialogue()
var battlefield: Node2D = preload("res://Scenes/main.tscn").instantiate()
var battlefield_player: CharacterBody2D = battlefield.get_node("Player")
var battlefield_player_color: Color = battlefield_player.soul
var battlefield_player_origin: Vector2 = battlefield_player.global_position
var battlefield_player_scale: Vector2 = battlefield_player.global_scale
var battlefield_villian_sprite: AnimatedSprite2D = battlefield.get_node("Villian/AnimatedSprite2D")
var battle_fall: bool = false

@onready var speaker_sprite: AnimatedSprite2D = $SpeakerSprite
@onready var text_label: RichTextLabel = $TextLabel
@onready var sound_player: AudioStreamPlayer = $SoundPlayer
@onready var right_hand_animation_player: AnimationPlayer = owner.get_node("RightHand/AnimationPlayer")
@onready var background: Node2D = owner.get_node("Background")
@onready var main: Node2D = owner.get_node("Main")
@onready var face: AnimatedSprite2D = owner.get_node("Face")
@onready var right_hand: AnimatedSprite2D = owner.get_node("RightHand")
@onready var box: Sprite2D = owner.get_node("Box")
@onready var snack: Node2D = owner.get_node("Snack")
@onready var soul: Sprite2D = owner.get_node("Soul")
@onready var camera: Camera2D = owner.get_node("Camera2D")
@onready var walking_sound_effect: AudioStreamPlayer = owner.get_node("WalkingSoundEffect")
@onready var eating_sound_effect: AudioStreamPlayer = owner.get_node("EatingSoundEffect")
@onready var background_music_player: AudioStreamPlayer = owner.get_node("BackgroundMusicPlayer")

func _ready() -> void:
	battlefield = null
	battlefield_player = null
	soul.self_modulate = battlefield_player_color
	hide()
	text_label.text = ""
	update_dialogue()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("accept") and on_queue and skipable:
		text_label.text = ""
		if stacked_dialogues.size() > 0:
			set_dialogues(stacked_dialogues)
		elif stacked_dialogues.size() == 0:
			on_queue = false
			skipable = false
			hide()
			
			if dialogue_index == 26:
				for owner_child in owner.get_children():
					if owner_child not in [get_parent(), face, soul, camera, walking_sound_effect, eating_sound_effect, background_music_player]:
						owner_child.hide()
					elif owner_child == face:
						var mask: Sprite2D = face.get_node("Mask")
						var mouth: Sprite2D = face.get_node("Mouth")
						var residue_particles: GPUParticles2D = face.get_node("ResidueParticles")
						
						face.frame = 4
						face.global_position = Vector2(638.054, 97.766)
						face.global_rotation_degrees = -10
						face.global_scale = Vector2(0.229, 0.228)
						mask.hide()
						mouth.hide()
						residue_particles.hide()
					elif owner_child == background_music_player:
						owner_child.stop()
				
				soul.show()
				await Transition.blink(get_parent(), 2)
				
				var battle_fall_sound_length: float = Audio.play_sound_and_return_length("battlefall")
				
				create_tween().tween_property(soul, "global_position", battlefield_player_origin, battle_fall_sound_length)
				create_tween().tween_property(soul, "global_scale", battlefield_player_scale, battle_fall_sound_length)
				create_tween().tween_property(face, "global_position", battlefield_villian_sprite.global_position, battle_fall_sound_length)
				create_tween().tween_property(face, "global_rotation_degrees", battlefield_villian_sprite.global_rotation_degrees, battle_fall_sound_length)
				create_tween().tween_property(face, "global_scale", battlefield_villian_sprite.global_scale, battle_fall_sound_length)
				await time.sleep(battle_fall_sound_length)
				
				get_tree().change_scene_to_file("res://Scenes/main.tscn")

func update_dialogue() -> void:
	if unknown:
		if speaker_sprite.visible:
			speaker_sprite.hide()
		text_label.size = Vector2(900, 180)
		text_label.position = Vector2(32, 24)
	elif not unknown:
		if not speaker_sprite.visible:
			speaker_sprite.show()
		text_label.size = Vector2(690, 180)
		text_label.position = Vector2(200, 24)

func set_dialogue(content: String, delay_time: float = 0.03) -> void:
	on_queue = true
	skipable = false
	
	if dialogue_index == 13:
		face.show()
		right_hand.show()
		box.show()
		snack.show()
		backgound_appear_transition()
		await time.sleep(1.0)
	
	main.pause_walking_animation()
	show()
	
	if unknown:
		sound_player.stream = load("res://Sounds/snd_txt_unknown.ogg")
	else:
		sound_player.stream = load("res://Sounds/snd_txt_yifan.ogg")
	
	for character in "* {content}".format({"content": content.replace("\n", "\n  ")}):
		text_label.text += character
		if not sound_player.playing and os.is_alpha(character):
			sound_player.play()
		elif sound_player.playing and not os.is_alpha(character):
			sound_player.stop()
		
		if not unknown:
			if not speaker_sprite.is_playing() and os.is_alpha(character):
				speaker_sprite.play("speaking")
			elif speaker_sprite.is_playing() and not os.is_alpha(character):
				speaker_sprite.stop()
		await time.sleep(delay_time)
	
	if sound_player.playing:
		sound_player.stop()
	if speaker_sprite.is_playing():
		speaker_sprite.stop()
	skipable = true
	dialogue_index += 1

func set_dialogues(contents: PackedStringArray, delay_time: float = 0.03) -> void:
	set_dialogue(contents[0], delay_time)
	contents.remove_at(0)
	stacked_dialogues = contents

func trigger_dialogue() -> void:
	if dialogue_index == 0:
		set_dialogue([
			"Hohoho... Look who's here!",
			"哎哟。。。 瞧瞧是谁来啦？",
			"哎哟。。。 瞧瞧是谁来矣？",
			"Aiyoyo... Lihat siapa yang datang ni?",
			"あらら... 誰が来たのを見てごらん？"
		][db.data.settings.language])
	elif dialogue_index == 1:
		set_dialogue([
			"To be honest, I didn't anticipate\nyou going this far...",
			"坦白说，我没预料到你会走到这么远。",
			"諒真言，吾未預料尔能行至此般遠。",
			"Secara jujurnya, saya tidak menjangka kamu dapat pergi sejauh ini.",
			"正直に言って、あなたがここまで進むとは予想していませんでした。"
		][db.data.settings.language])
	elif dialogue_index == 2:
		set_dialogue([
			"For such a long time, I've been\neagerly awaiting this moment.\nHuahahaha...",
			"我等这一刻，已经等了好久。哗哈哈哈。。。",
			"吾候斯刻，已候久矣。哗哈哈哈。。。",
			"Saya sudah menunggu momen ini begitu lama.",
			"この瞬間をずっと待っていました..."
		][db.data.settings.language])
	elif dialogue_index == 3:
		set_dialogues([
			[
				"Consider this your final warning.\nTake a few more steps, and there\nwill be no turning back.",
				"...",
				"If...",
				"If by chance you have any\nunfinished buisness...",
				"Please do what you must."
			],
			[
				"不要说我没警告你，再走多几步就没有回头路了。",
				"。。。",
				"如果。。。",
				"如果说你现在还有未完成的事情。。。",
				"那就请你先完成了它们再回来也不迟。"
			],
			[
				"以此为尔最后之警告。再行数步，当不复返矣。",
				"。。。",
				"若。。。",
				"若尔偶尚有未竟之事。。。",
				"是則請尔先辦畢其事再歸亦無晚矣。"
			],
			[
				"Anggap ini sebagai amaran terakhirmu. Teruskan beberapa langkah lagi, dan kamu akan tiada jalan kembali lagi.",
				"...",
				"Jika...",
				"Jika kamu ada urusan yang belum selesai lagi...",
				"Sila selesaikan urusan itu baru balik sini."
			],
			[
				"これを最後の警告と考えなさい。もう少し進んだなら、引き返すことはできません。",
				"。。。",
				"もし。。。",
				"もし、まだ終わっていない仕事があるなら。。。",
				"それらを先に終わらせてから戻ってきてください。"
			]
		][db.data.settings.language])

func backgound_appear_transition() -> void:
	create_tween().tween_property(main, "self_modulate:a", 1, 0.7)
	create_tween().tween_property(background, "modulate:a", 1, 1.0)
	right_hand_animation_player.play("take_super_ring")
