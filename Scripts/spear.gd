@tool
extends Area2D

enum DIRECTION {
	UP,
	RIGHT,
	DOWN,
	LEFT
}
var velocity: Vector2 = Vector2.ZERO
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
@export var speed: int = 100
@export var damage_multiplier: int = 2
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _process(delta):
	if not Engine.is_editor_hint():
		if direction == DIRECTION.UP:
			velocity.y = -speed * delta
		elif direction == DIRECTION.RIGHT:
			velocity.x = speed * delta
		elif direction == DIRECTION.DOWN:
			velocity.y = speed * delta
		elif direction == DIRECTION.LEFT:
			velocity.x = -speed * delta
		translate(velocity)

func _on_body_entered(body):
	if not Engine.is_editor_hint() and body.is_in_group("player"):
		var spear_spawner: Node2D = player.get_node("SpearAttack/Spawner")
		
		body.deal_damage(villain.attack * damage_multiplier)
		spear_spawner.destroy_spear_and_locate_red_spear(self)
