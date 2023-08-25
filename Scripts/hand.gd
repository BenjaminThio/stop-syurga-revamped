@tool
extends Sprite2D

enum DIRECTION {
	RIGHT,
	DOWN,
	LEFT,
	UP
}

var rotation_vector: Vector2 = Vector2.ZERO
var fireball_scene: PackedScene = preload("res://Instances/fireball.tscn")

@export var direction: DIRECTION = DIRECTION.RIGHT:
	get:
		return direction
	set(value):
		direction = value
		if direction == DIRECTION.RIGHT:
			rotation_degrees = 0
		elif direction == DIRECTION.DOWN:
			rotation_degrees = 90
		elif direction == DIRECTION.LEFT:
			rotation_degrees = 180
		elif direction == DIRECTION.UP:
			rotation_degrees = 270
@export var move_distance: int = 300
@export var transition_duration: float = 1.0
@export var fireball_spawn_gap_duration: float = 0.17
@export var fireball_move_delay_duration: float = 0.1

@onready var main: Node2D = get_tree().get_root().get_node_or_null("Main")

func _ready():
	await time.sleep(0.001)
	if not Engine.is_editor_hint() and main != null:
		var tween: Tween = create_tween()
		
		rotation_vector = Vector2(move_distance, 0).rotated(rotation)
		tween.tween_property(self, "position", Vector2(position.x + rotation_vector.x, position.y + rotation_vector.y), transition_duration)
		while tween.is_running():
			var fireball: Area2D = fireball_scene.instantiate()
			
			main.add_child(fireball)
			fireball.spawner_id = get_instance_id()
			fireball.global_position = global_position
			
			await time.sleep(fireball_spawn_gap_duration)
		
		hide()
		
		await time.sleep(fireball_move_delay_duration)
		
		var fireballs: Array[Node] = get_tree().get_nodes_in_group("fireball")
		
		for fireball in fireballs:
			if fireball.spawner_id == get_instance_id():
				fireball.get_rotation_vector()
		
		queue_free()
