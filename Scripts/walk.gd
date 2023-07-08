extends Node2D

const METER_TO_CHI: float = 3.0303

var walking: bool = false
var view_shaking: bool = false
var view_shake_time: float = 0.15
var last_phase: bool = false
var flashlight_switched_on: bool = false
var brigthness: Dictionary = {
	flashlight_on = {
		flashlight_start_value = 50.0 / 255.0,
		flashlight_end_value = 127.5 / 255.0,
		obstacles_start_value = 50.0 / 255.0,
		obstacles_end_value = 255.0 / 255.0
	},
	flashlight_off = {
		obstacles_start_value = 30.0 / 255.0,
		obstacles_end_value = 70.0 / 255.0
	}
}
var walking_animation_length: float = 20.0
var walking_animation_elapsed_time: float = 0
var walking_animation_time_left: float = walking_animation_length - walking_animation_elapsed_time
var flashlight_tween: Tween = null
var obstacles_tween: Tween = null
@onready var flashlight: Sprite2D = $Flashlight
@onready var shadow: Sprite2D = $Shadow
@onready var obstacles: Sprite2D = $Obstacles
@onready var walking_animation_player: AnimationPlayer = $AnimationPlayer
@onready var blur_effect: ColorRect = owner.get_node("Canvas/BlurEffect")
@onready var dialogue: NinePatchRect = owner.get_node("Canvas/Dialogue")
@onready var hints_label: Label = owner.get_node("Canvas/HintsLabel")
@onready var distance_label: Label = owner.get_node("Canvas/DistanceLabel")
@onready var debug_label: Label = owner.get_node("Canvas/DebugLabel")
@onready var walking_sound_effect: AudioStreamPlayer = owner.get_node("WalkingSoundEffect")
@onready var background_music_player: AudioStreamPlayer = owner.get_node("BackgroundMusicPlayer")

func _ready() -> void:
	hints_label.text = [
		"Press UP key to move forward.\nPress F key to switch on flashlight.",
		"按“上”键向前移动。\n按“F”键打开手电筒。",
		"按「上」鍵向前移動。\n按「F」鍵開啟手電筒。",
		"Tekan kekunci ATAS untuk bergerak ke hadapan.\nTekan kekunci F untuk menghidupkan lampu suluh.",
		"上キーを押して前に進んでください。\nFキーを押して懐中電灯を点灯してください。"
	][db.data.settings.language]
	distance_label.hide()
	
	if flashlight_switched_on:
		flashlight.show()
		shadow.show()
		
		flashlight.self_modulate.a = brigthness.flashlight_on.flashlight_start_value
		obstacles.self_modulate.a = brigthness.flashlight_on.obstacles_start_value
	elif not flashlight_switched_on:
		flashlight.hide()
		shadow.hide()
		
		obstacles.self_modulate.a = brigthness.flashlight_off.obstacles_start_value

func _process(_delta) -> void:
	#print(flashlight_tween, obstacles_tween)
	
	if Input.is_action_just_pressed("flashlight") and not last_phase:
		if hints_label.visible:
			hints_label.hide()
		
		flashlight_switched_on = not flashlight_switched_on
		update_flashlight()
	
	if dialogue.on_queue or last_phase:
		return
		
	if Input.is_action_pressed("up") and not view_shaking:
		view_shaking = true
		
		if not walking_sound_effect.playing:
			walking_sound_effect.play()
		
		if walking_animation_player.process_mode == PROCESS_MODE_DISABLED:
			walking_animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
		
		walking_animation_length = walking_animation_player.current_animation_length
		walking_animation_elapsed_time = walking_animation_player.current_animation_position
		walking_animation_time_left = walking_animation_length - walking_animation_elapsed_time
		
		if flashlight_tween == null and flashlight_switched_on:
			flashlight_tween = create_tween()
			flashlight_tween.tween_property(flashlight, "self_modulate:a", brigthness.flashlight_on.flashlight_end_value, walking_animation_time_left)
		if obstacles_tween == null:
			obstacles_tween = create_tween()
			if flashlight_switched_on:
				obstacles_tween.tween_property(obstacles, "self_modulate:a", brigthness.flashlight_on.obstacles_end_value, walking_animation_time_left)
			elif not flashlight_switched_on:
				obstacles_tween.tween_property(obstacles, "self_modulate:a", brigthness.flashlight_off.obstacles_end_value, walking_animation_time_left)
			
		if hints_label.visible:
			hints_label.hide()
		if not distance_label.visible:
			distance_label.show()
		
		distance_label.text = [
			"{distance_to_dst} m left".format({"distance_to_dst": round(walking_animation_time_left)}),
			"还剩{distance_to_dst}米".format({"distance_to_dst": round(walking_animation_time_left)}), 
			"剩餘{distance_to_dst}尺".format({"distance_to_dst": round(walking_animation_time_left * METER_TO_CHI)}),
			"Masih ada {distance_to_dst} m".format({"distance_to_dst": round(walking_animation_time_left)}),
			"{distance_to_dst}メートル残っています".format({"distance_to_dst": round(walking_animation_time_left)})
		][db.data.settings.language]
		
		if ceil(walking_animation_time_left) > 0:
			walking = true
			view_shaking = true
			for direction_index in range(2):
				if walking:
					var flashlight_shake_index: float = 2
					
					if walking_animation_player.current_animation_position > 4:
						flashlight_shake_index = walking_animation_player.current_animation_position / 2
					create_tween().tween_property(flashlight, "position:x", flashlight_shake_index * [-1, 1][direction_index], view_shake_time)
					await create_tween().tween_property(self, "rotation_degrees", 0.5 * [-1, 1][direction_index], view_shake_time).finished
					await create_tween().tween_property(self, "rotation_degrees", 0, view_shake_time).finished
				else:
					break
			view_shaking = false
		elif ceil(walking_animation_time_left) == 0 and not last_phase:
			last_phase = true
			dialogue.unknown = false
			distance_label.hide()
			pause_walking_animation()
			if flashlight_switched_on:
				flashlight_switched_on = false
				update_flashlight()
			
			await time.sleep(0.5)
			
			background_music_player.stream = load("res://Musics/mus_encounter.ogg")
			background_music_player.play()
			
			create_tween().tween_property(obstacles, "global_position", Vector2(513.6, 510), 1)
			create_tween().tween_property(obstacles, "global_scale", Vector2(1.2, 1.2), 1)
			create_tween().tween_property(obstacles, "self_modulate:a", 0.7, 1)
			create_tween().tween_method(set_blurriness, 10, 0, 1)
			
			await time.sleep(1.0)
			
			#var random_last_words: String = random.choice(["and must be paid back by\nblood!!!", "and you will face the\nconsequences!!!"])
			
			dialogue.set_dialogues([
				[
					"Oh, my dear, it feels\nlike an eternity since\nwe last crossed paths.\nHave you been pining for\nme?",
					"What a lengthy trip it\nwas, huh?",
					"I'm sure it must have\nleft you feeling worn\nout.",
					"...",
					"I can't forget the way\nwe fell in love, nor can\nI forget how we\neventually broke up and\nended up in this\nchallenging situation...",
					"Remember this place?",
					"...",
					"......",
					"It marks our first\nencounter...",
					"Those were beautiful\ntimes.",
					"Regrettably, it cannot\nbe undone.",
					"It was your own hands\nthat shattered it all.",
					"You are a liar and\nbetrayer...",
					"You made promises with\nme of a better life and\neverlasting love...",
					"But in the end, you\nrepent...",
					"You ruined my entire\nlife!!!",
					"and now...",
					"I will let you pay back\nby blood!!!"
				],
				[
					"哦，亲爱的，自从我们上一次也是最后一次的会面以来，就好像永恒，你是否想念我了呢？",
					"真是一个漫长的旅途啊。",
					"我想这一定把你累坏了吧？",
					"。。。",
					"我还是忘不掉当时的我们是如何醉入爱河，而到最后竟落得如此下场的。",
					"还记得这里吗？",
					"。。。",
					"。。。。。。",
					"这是我们第一次相遇的地方。",
					"那些我们在一起的时光是多么的美好。",
					"可惜啊，一切都不能重来了。",
					"一切的一切都是你一手造成。",
					"你这个骗子和叛徒。",
					"你曾经答应过我你会给我更好的生活和永恒的爱。",
					"但到最后，你出尔反尔。",
					"你毁掉我美好的人生！！！",
					"所以现在。。。",
					"我要让你血债血偿！！！"
				],
				[
					"哦，吾亲爱者，尔已逾时未交。尔犹怀吾乎？",
					"真是個漫長之旅啊。",
					"吾意此必疲惫尔乎？",
					"。。。",
					"吾猶忘弗去，當時吾輩如何陶醉於愛河之中，而結局竟至如此下場。",
					"猶記此處否？",
					"。。。",
					"。。。。。。",
					"是吾等初次相遇之地。",
					"此起共处之光辉，堪称绝美。",
					"惜哉，一切不能复返。",
					"一切的一切皆由尔所致。",
					"尔此为诈者及叛徒也。",
					"尔曾答吾之誓，欲以更美好之生活与永恒之爱予吾。",
					"然至终，尔食言了",
					"尔毁吾之一生！！！",
					"是以今日...",
					"吾欲使尔以己血偿还！！！"
				],
				[
					"Oh, sayangku, rasanya seperti keabadian sejak kita terakhir bertemu. Adakah kamu merindui aku?",
					"Perjalanan ini memang panjang.",
					"Saya rasa ini pasti membuatmu letih, kan?",
					"...",
					"Saya masih tidak boleh melupakan bagaimana kita saling mencintai, dan akhirnya berakhir dengan situasi mencabar macam ini.",
					"Masih ingat tempat ini?",
					"...",
					"......",
					"Tempat ini ialah tempat yang kita pertama kali bertemu.",
					"Masa yang kita bersama adalah begitu indah.",
					"Sayangnya, semuanya tidak dapat diulang lagi.",
					"Kau yang menyebabkan semuanya.",
					"kau memang seorang penipu dan pengkhianat.",
					"Kau pernah berjanji dengan saya agar memberi kehidupan yang lebih baik dan cinta yang abadi kepada saya.",
					"Tetapi pada akhirnya, kau melanggar janjimu.",
					"Kau telah menghancurkan seluruh kehidupan saya!!!",
					"Jadi sekarang...",
					"Saya ingin engkau membalas dengan darahmu!!!"
				],
				[
					"ああ、私の愛しい人よ、最後に出会ってから永遠のような気がします。私のことを懐かしんでいましたか？",
					"本当に長い旅路だな。",
					"きっと君は疲れ果てているだろうね？",
					"。。。",
					"今でも忘れられない、当時の僕たちがいかに愛の川に酔いしれ、そして最後はこんな結末になったのか。",
					"この場所を覚えていますか？",
					"。。。",
					"。。。。。。",
					"これは私たちが初めて出会った場所です。",
					"一緒に過ごした時間は何と素晴らしかったことでしょう。",
					"残念ですね、すべてをやり直すことはできません。",
					"すべてはあなたによって引き起こされたものです。",
					"お前は詐欺師であり、裏切り者だ。",
					"かつて、あなたは私により良い生活と永遠の愛を約束した。",
					"しかし最後には、あなたは約束を破った。",
					"お前は俺の人生を台無しにした！！！",
					"だから今は。。。",
					"お前に自らの血で償わせる！！！",
				]
			][db.data.settings.language])
	if Input.is_action_just_released("up"):
		pause_walking_animation()

func update_flashlight():
	if flashlight_switched_on:
		flashlight.show()
		shadow.show()
		
		flashlight.self_modulate.a = brigthness.flashlight_on.flashlight_start_value + ((brigthness.flashlight_on.flashlight_end_value - brigthness.flashlight_on.flashlight_start_value) * walking_animation_elapsed_time / walking_animation_length)
		obstacles.self_modulate.a = brigthness.flashlight_on.obstacles_start_value + ((brigthness.flashlight_on.obstacles_end_value - brigthness.flashlight_on.obstacles_start_value) * walking_animation_elapsed_time / walking_animation_length)
		
		if flashlight_tween != null:
			flashlight_tween.kill()
			flashlight_tween = create_tween()
			flashlight_tween.tween_property(flashlight, "self_modulate:a", brigthness.flashlight_on.flashlight_end_value, walking_animation_time_left)
		
		if obstacles_tween != null:
			obstacles_tween.kill()
			obstacles_tween = create_tween()
			obstacles_tween.tween_property(obstacles, "self_modulate:a", brigthness.flashlight_on.obstacles_end_value, walking_animation_time_left)
		
		Audio.play_sound("flashlight_on")
	elif not flashlight_switched_on:
		flashlight.hide()
		shadow.hide()
		
		obstacles.self_modulate.a = brigthness.flashlight_off.obstacles_start_value + ((brigthness.flashlight_off.obstacles_end_value - brigthness.flashlight_off.obstacles_start_value) * walking_animation_elapsed_time / walking_animation_length)
		
		if obstacles_tween != null:
			obstacles_tween.kill()
			obstacles_tween = create_tween()
			obstacles_tween.tween_property(obstacles, "self_modulate:a", brigthness.flashlight_off.obstacles_end_value, walking_animation_time_left)
			
		Audio.play_sound("flashlight_off")
		
func pause_walking_animation() -> void:
	if walking_sound_effect.playing:
		walking_sound_effect.stop()
	
	if walking_animation_player.process_mode == PROCESS_MODE_ALWAYS:
		walking_animation_player.process_mode = Node.PROCESS_MODE_DISABLED
		
		if flashlight_switched_on and flashlight_tween != null:
			flashlight_tween.kill()
			flashlight_tween = null
		if obstacles_tween != null:
			obstacles_tween.kill()
			obstacles_tween = null
		
		walking = false

func set_blurriness(value: int) -> void:
	blur_effect.material.set_shader_parameter("blurriness", value)
