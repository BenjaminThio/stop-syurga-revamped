extends Area2D

enum DIRECTION {
	LEFT,
	RIGHT
}
var velocity: Vector2 = Vector2.ZERO
@export var direction: DIRECTION = DIRECTION.RIGHT
@export var speed: int = 100
@export var damage_multiplier: int = 2
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")

func _process(delta):
	if direction == DIRECTION.LEFT:
		velocity.x = -speed * delta
	elif direction == DIRECTION.RIGHT:
		velocity.x = speed * delta
	translate(velocity)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack * damage_multiplier)

func _on_visible_on_screen_notifier_screen_exited():
	queue_free()
