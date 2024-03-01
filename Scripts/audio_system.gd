extends Node2D

@onready var master_audio_volume_slider: TextureRect = $Master/Slider
@onready var bgm_audio_volume_slider: TextureRect = $Bgm/Slider
@onready var sfx_audio_volume_slider: TextureRect = $Sfx/Slider

func set_interactable(interactable: bool):
	for audio_volume_slider in [master_audio_volume_slider, bgm_audio_volume_slider, sfx_audio_volume_slider] as Array[TextureRect]:
		audio_volume_slider.interactable = interactable
