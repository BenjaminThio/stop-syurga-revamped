extends Node2D

var fleeing: bool = false

@onready var soul = $Soul

func _process(_delta):
	if Input.is_action_just_pressed("accept") and not fleeing:
		fleeing = true
		var flee_animated_sprite: AnimatedSprite2D = load("res://Instances/flee.tscn").instantiate()
		
		soul.add_child(flee_animated_sprite)
		create_tween().tween_property(flee_animated_sprite, "offset:y", 3, 0.5)
		
		await time.sleep(0.5)
		
		flee_animated_sprite.play("flee")
		
		await time.sleep(ModifiedSpriteFrames.get_frame_absolute_duration(flee_animated_sprite))
		
		create_tween().tween_property(soul, "position:x", soul.position.x - 100, 2)
		
		await time.sleep(2)
		
		flee_animated_sprite.stop()
		create_tween().tween_property(flee_animated_sprite, "offset:y", -4, 0.5)
		
		await time.sleep(0.5)
		
		flee_animated_sprite.queue_free()
		fleeing = false
