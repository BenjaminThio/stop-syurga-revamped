extends Node2D

var disabled_process_mode: bool = false
var game_over_screen: PackedScene = preload("res://Scenes/game_over.tscn")

@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer
@onready var player: CharacterBody2D = $Player
@onready var main_camera: Camera2D = $Camera2D

func _ready() -> void:
	if background_music_player.stream == null:
		play_audio("res://Musics/Stop Syurga.mp3")
	elif not background_music_player.playing and not background_music_player.autoplay:
		play_audio()
	else:
		loop_audio()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("test1"):
		set_pause(not disabled_process_mode)

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
	State.change_state(State.GAME_OVER)
	
	for child in get_children():
		if child not in [player, main_camera]:
			child.queue_free()
	
	await player.heart_break()
	
	add_child(game_over_screen.instantiate())

func set_pause(pause: bool):
	disabled_process_mode = pause
	
	for child in get_children():
		if disabled_process_mode:
			child.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			child.process_mode = Node.PROCESS_MODE_INHERIT
