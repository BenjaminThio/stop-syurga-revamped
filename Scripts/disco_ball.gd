extends Area2D

@onready var disco_ball_animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		var blink_sound_length: float = Audio.play_sound_and_return_length("blink")
		
		area.queue_free()
		disco_ball_animated_sprite.frame = 1
		
		await time.sleep(blink_sound_length)
		
		disco_ball_animated_sprite.frame = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack)
