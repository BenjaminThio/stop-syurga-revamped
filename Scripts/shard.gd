extends AnimatedSprite2D

const SPEED: int = 3
const GRAVITY: float = 1

var random_distance: int = randi_range(-70, 70)
var random_jump_force: int = randi_range(-20, 100)
var velocity: Vector2 = Vector2(random_distance, -random_jump_force)

func _process(delta):
	global_position += velocity * SPEED * delta
	velocity.y += GRAVITY
