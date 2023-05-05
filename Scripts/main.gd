extends Node2D

var is_game_over: bool = false

@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer

func _ready() -> void:
	if background_music_player.stream == null:
		play_audio("res://Musics/Stop Syurga.mp3")
	elif not background_music_player.playing and not background_music_player.autoplay:
		play_audio()
	else:
		loop_audio()

func play_sound_effect(sound_name: String) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	
	add_child(audio_stream_player)
	audio_stream_player.stream = load("res://Sounds/{sound_name}.wav".format({"sound_name": sound_name.capitalize()}))
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)

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

func game_over() -> void:
	is_game_over = true
	
	var player: CharacterBody2D = $Player
	var main_camera: Camera2D = $Camera2D
	
	for child in get_children():
		if child not in [player, main_camera]:
			child.queue_free()
	
	await player.heart_break()
	
	var game_over_screen: Control = load("res://Scenes/game_over.tscn").instantiate()
	
	add_child(game_over_screen)

func set_pause(pause: bool):
	for child in get_children():
		if pause:
			child.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			child.process_mode = Node.PROCESS_MODE_INHERIT
