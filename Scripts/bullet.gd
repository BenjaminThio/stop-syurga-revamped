extends Area2D

const SPEED: int = 300
var velocity: Vector2 = Vector2.ZERO

func _process(delta) -> void:
	velocity.y = -SPEED * delta
	translate(velocity)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
