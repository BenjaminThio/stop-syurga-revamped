extends Node2D

@onready var slay_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var slay_audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	rotation_degrees = randf_range(0, 360)
	slay_animation.play("slay")
	slay_animation.animation_finished.connect(queue_free)
	slay_audio_player.play()
