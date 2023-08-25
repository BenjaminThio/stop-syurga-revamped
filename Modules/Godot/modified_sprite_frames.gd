extends Node

class_name ModifiedSpriteFrames

static func get_frame(animated_sprite: AnimatedSprite2D, animation_index: int = 0, frame_index: int = 0) -> Texture2D:
	var sprite_frames: SpriteFrames = animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	var sprite_frame: Texture2D = sprite_frames.get_frame_texture(animation_names[animation_index], frame_index)
	
	return sprite_frame

static func get_frame_absolute_duration(animated_sprite: AnimatedSprite2D, animation_index: int = 0, frame_index: int = 0) -> float:
	var sprite_frames: SpriteFrames = animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	var animation_frame_relative_duration: float = sprite_frames.get_frame_duration(animation_names[animation_index], frame_index)
	var animation_fps: float = sprite_frames.get_animation_speed(animation_names[animation_index])
	var animated_sprite_playing_speed: float = animated_sprite.get_playing_speed()
	
	return animation_frame_relative_duration / animation_fps * abs(animated_sprite_playing_speed)

static func get_animation_absolute_duration(animated_sprite: AnimatedSprite2D, animation_index: int = 0) -> float:
	var sprite_frames: SpriteFrames = animated_sprite.get_sprite_frames()
	var animation_names: PackedStringArray = sprite_frames.get_animation_names()
	var animation_duration: float = 0
	
	for frame_index in range(sprite_frames.get_frame_count(animation_names[animation_index])):
		animation_duration += get_frame_absolute_duration(animated_sprite, animation_index, frame_index)
	return animation_duration
