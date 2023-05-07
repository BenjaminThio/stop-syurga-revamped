extends Node

class_name ModifiedSpriteFrames

static func get_frame_absolute_duration(animated_sprite: AnimatedSprite2D, animation_index: int = 0, frame_index: int = 0) -> float:
	var sprite_frames: SpriteFrames = animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	var animation_frame_relative_duration: float = sprite_frames.get_frame_duration(animation_names[animation_index], frame_index)
	var animation_fps: float = sprite_frames.get_animation_speed(animation_names[animation_index])
	var animated_sprite_playing_speed: float = animated_sprite.get_playing_speed()
	
	return animation_frame_relative_duration / animation_fps * abs(animated_sprite_playing_speed)
