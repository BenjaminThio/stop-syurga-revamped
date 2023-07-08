@tool
extends Area2D

enum DIRECTION {
	UP,
	RIGHT,
	DOWN,
	LEFT
}
var velocity: Vector2 = Vector2.ZERO
var reversed: bool = true
var rotating: bool = false
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@export var direction: DIRECTION = DIRECTION.UP:
	get:
		return direction
	set(value):
		direction = value
		if direction == DIRECTION.UP:
			rotation_degrees = 0
		elif direction == DIRECTION.RIGHT:
			rotation_degrees = 90
		elif direction == DIRECTION.DOWN:
			rotation_degrees = 180
		elif direction == DIRECTION.LEFT:
			rotation_degrees = 270
@export var speed: int = 200
@export var rotate_within_distance: int = 90
@export var rotate_time: float = 0.3

func _process(delta):
	if not Engine.is_editor_hint():
		if reversed and self.global_position.distance_to(owner.global_position) <= rotate_within_distance:
			reversed = false
			rotating = true
			create_tween().tween_property(self, "rotation_degrees", self.rotation_degrees + 180, rotate_time)
			create_tween().tween_property(owner, "rotation_degrees", owner.rotation_degrees - 180, rotate_time)
			await time.sleep(rotate_time)
			rotating = false
		if not rotating:
			if direction == DIRECTION.UP:
				velocity.y = speed * delta
			elif direction == DIRECTION.RIGHT:
				velocity.x = -speed * delta
			elif direction == DIRECTION.DOWN:
				velocity.y = -speed * delta
			elif direction == DIRECTION.LEFT:
				velocity.x = speed * delta
			translate(velocity)

func _on_body_entered(body):
	if not Engine.is_editor_hint() and body.is_in_group("player"):
		body.deal_damage(villian.attack * 2)
		owner.queue_free()
