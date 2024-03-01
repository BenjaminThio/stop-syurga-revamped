extends Node2D

@export var bgm_start_position: float = 2.0

var play_music: bool = false
var play_sound: bool = false

@onready var bgm_audio_player: AudioStreamPlayer = $Bgm
@onready var sfx_audio_player: AudioStreamPlayer = $Sfx
@onready var play_music_button: Button = $PlayMusic
@onready var play_sound_button: Button = $PlaySound

func _on_play_music_pressed():
	play_music = not play_music
	
	if play_music:
		bgm_audio_player.play(bgm_start_position)
	else:
		bgm_audio_player.stop()
	
	play_music_button.text = [
		"Play Music",
		"Stop Music"
	][int(play_music)]

func _on_play_sound_pressed():
	play_sound = not play_sound
	
	if play_sound:
		sfx_audio_player.play()
	else:
		sfx_audio_player.stop()
	
	play_sound_button.text = [
		"Play Sound",
		"Stop Sound"
	][int(play_music)]
