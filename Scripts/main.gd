extends Node2D

var disabled_process_mode: bool = false
var game_over_screen: PackedScene = preload("res://Instances/game_over.tscn")

@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer
@onready var player: CharacterBody2D = $Player
@onready var main_camera: Camera2D = $Camera2D

func play_background_music():
	if background_music_player.stream == null:
		play_audio("res://Musics/mus_stop_syurga.ogg")
	elif not background_music_player.playing and not background_music_player.autoplay:
		play_audio()
	else:
		loop_audio()

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
	State.set_state(State.MAIN_STATE.GAME_OVER)
	
	background_music_player.stop()
	
	for child in get_children():
		if child not in [player, main_camera, background_music_player]:
			child.queue_free()
		elif child == player:
			var player_green: Node2D = player.get_node("Green")
			var spear_spawner: Node2D = player.get_node("SpearAttack/Spawner")
			
			if player_green.visible:
				player_green.hide()
			if spear_spawner.get_child_count() > 0:
				for spear in spear_spawner.get_children():
					spear.queue_free()
	
	await player.heart_break()
	
	add_child(game_over_screen.instantiate())

func set_pause(pause: bool):
	disabled_process_mode = pause
	
	for child in get_children():
		if disabled_process_mode:
			child.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			child.process_mode = Node.PROCESS_MODE_INHERIT
