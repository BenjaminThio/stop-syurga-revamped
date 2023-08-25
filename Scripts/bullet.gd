extends Area2D

@export var speed: int = 350
var velocity: Vector2 = Vector2.ZERO

func _process(delta) -> void:
	velocity.y = -speed * delta
	translate(velocity)

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()
