@tool
extends Node2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.LEFT:
	get:
		return direction
	set(value):
		direction = value
		if direction == DIRECTION.LEFT:
			scale.x = 1
		elif direction == DIRECTION.RIGHT:
			scale.x = -1
@export var move: bool = false:
	get:
		return move
	set(value):
		move = value
		update_leg_color()
@export var move_distance: float = 100
@export var damage_multiplier: int = 2
@export var transition_duration: float = 0.8
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@onready var leg_area: Area2D = $Area
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
var tween: Tween = null
var move_speed: float

func _ready():
	move_speed = move_distance / transition_duration
	update_leg_color()

func _process(_delta):
	if not Engine.is_editor_hint() and move and tween == null:
		transition_duration = leg_area.position.distance_to(Vector2(move_distance, 0)) / move_speed
		tween = create_tween().set_trans(transition_type)
		tween.tween_property(leg_area, "position:x", move_distance, transition_duration).finished.connect(
			func() -> void:
				tween.kill()
				tween = null
				move_distance *= -1
		)
	if Input.is_action_just_pressed("ui_accept"):
		move = not move
		if tween != null:
			tween.kill()
			tween = null
		update_leg_color()

func update_leg_color():
	if move:
		modulate = Color.YELLOW
	else:
		modulate = Color.WHITE

func _on_leg_area_entered(area):
	if not Engine.is_editor_hint() and area.is_in_group("bullet"):
		area.queue_free()
		move = not move
		if tween != null:
			tween.kill()
			tween = null
		update_leg_color()

func _on_leg_body_entered(body):
	if not Engine.is_editor_hint() and body.is_in_group("player"):
		body.deal_damage(villian.attack * damage_multiplier)
