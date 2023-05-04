extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.self_modulate = Color.BLUE

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		var ghost: Sprite2D = Sprite2D.new()
		var sprite_frames: SpriteFrames = animated_sprite.get_sprite_frames()
		var animation_names: PackedStringArray = sprite_frames.get_animation_names()
		
		ghost.texture = sprite_frames.get_frame_texture(animation_names[0], 0)
		ghost.global_scale = animated_sprite.global_scale
		ghost.self_modulate = Color.BLUE
		animated_sprite.add_child(ghost)
		create_tween().tween_property(ghost, "scale", ghost.scale * 2, 0.5)
		create_tween().tween_property(ghost, "self_modulate:a", 0, 0.5)
		await time.sleep(0.5, ghost.queue_free)
