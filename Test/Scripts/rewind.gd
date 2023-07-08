extends Node2D

var rewind: bool = false
var cancel_counter: int = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_label: Label = $State

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		if not animation_player.is_playing():
			cancel_counter = 0
			state_label.text = "REC"
			animation_player.play("move_icon")
		else:
			rewind = not rewind
			if rewind:
				var current_animation_length_left: float = animation_player.current_animation_length - animation_player.current_animation_position
				
				state_label.text = "REW"
				animation_player.stop()
				animation_player.play_backwards("move_icon")
				animation_player.advance(current_animation_length_left)
			else:
				var current_animation_position: float = animation_player.current_animation_position
				
				state_label.text = "REC"
				animation_player.stop()
				animation_player.play("move_icon")
				animation_player.advance(current_animation_position)
	elif Input.is_action_just_pressed("cancel"):
		if cancel_counter == 0 and animation_player.is_playing():
			cancel_counter += 1
			state_label.text = "PAUSE"
			animation_player.pause()
		elif cancel_counter > 0:
			cancel_counter = 0
			state_label.text = "STOP"
			animation_player.stop()
