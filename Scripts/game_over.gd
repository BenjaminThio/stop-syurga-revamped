extends Control

var quotes: Array[String] = ["You cannot give\nup just yet..."] #["The future of\nmonsters depends\non you!", "Don't lose hope!", 
var on_queue: bool = false
var phases: int = 0

@onready var game_over_label: Label = $Title
@onready var quote_label: Label = $Quote
@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer

func _ready() -> void:
	game_over_label.self_modulate.a = 0
	quote_label.text = ""
	background_music_player.volume_db = 0
	
	if background_music_player.stream == null:
		play_audio("res://Musics/Game Over.mp3")
	elif not background_music_player.playing and not background_music_player.autoplay:
		play_audio()
	else:
		loop_audio()
	
	on_queue = true
	create_tween().tween_property(game_over_label, "self_modulate:a", 1, 1.5)
	await time.sleep(1.5)
	on_queue = false
	
	var random_quote: String = random.choice(quotes)
	
	await asgore_say(random_quote)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("accept") and not on_queue:
		phases += 1
		quote_label.text = ""
		if phases == 1:
			await asgore_say("{name}!\nStay determined.".format({"name": db.human_name}))
		elif phases == 2:
			on_queue = true
			await time.sleep(3)
			create_tween().tween_property(game_over_label, "self_modulate:a", 0, 1.5)
			create_tween().tween_property(background_music_player, "volume_db", -10, 1.5)
			await time.sleep(1.5)
			on_queue = false
			
			get_tree().quit()

func asgore_say(quote: String) -> void:
	on_queue = true
	
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	
	for character in quote:
		quote_label.text += character
		if regex.search(character):
			play_sound_effect("Asgore Voice")
		await time.sleep(0.07)
	
	await time.sleep(5)
	
	on_queue = false

func play_audio(path: String = "", loop: bool = true) -> void:
	if path != "":
		background_music_player.stream = load(path)
	
	if not background_music_player.playing and not background_music_player.autoplay:
		background_music_player.play()
	else:
		push_warning("The audio's Playing/AutoPlay function has turned on, no need to play the audio again. Maybe you are looking for the `loop_audio()` function?")
	
	loop_audio(loop)

func loop_audio(loop: bool = true) -> void:
	if loop and not background_music_player.is_connected("finished", background_music_player.play):
		background_music_player.finished.connect(background_music_player.play)
	elif not loop and background_music_player.is_connected("finished", background_music_player.play):
		background_music_player.finished.disconnect(background_music_player.play)

func play_sound_effect(sound_name: String) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	
	add_child(audio_stream_player)
	audio_stream_player.stream = load("res://Sounds/{sound_name}.wav".format({"sound_name": sound_name.capitalize()}))
	audio_stream_player.pitch_scale = 1 + randf_range(-0.01, 0.01)
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)
