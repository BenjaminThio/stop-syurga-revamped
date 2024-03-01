extends Node

enum BUS {
	MASTER,
	BGM,
	SFX,
	SFX_ECHO
}

func play_sound(sound_name: String, pitch_scale: float = 1.0) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	
	instantiate_temp_sound(audio_stream_player, sound_name, pitch_scale)

func play_sound_and_return_length(sound_name: String, pitch_scale: float = 1.0) -> float:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	
	instantiate_temp_sound(audio_stream_player, sound_name, pitch_scale)
	return audio_stream_player.stream.get_length()

func instantiate_temp_sound(audio_stream_player: AudioStreamPlayer, sound_name: String, pitch_scale: float) -> void:
	add_child(audio_stream_player)
	audio_stream_player.stream = load("res://Sounds/snd_{sound_name_param}.wav".format({sound_name_param = sound_name}))
	audio_stream_player.pitch_scale = pitch_scale
	audio_stream_player.bus = "sfx"
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)
