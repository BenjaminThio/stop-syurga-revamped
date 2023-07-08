extends Node2D

@export var move_distance: float = 100
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var transition_duration: float = 0.5
@onready var leg_area: Area2D = $Area
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
var move: bool = false
var tween: Tween = null
var move_speed: float = move_distance / transition_duration

func _ready():
	update_leg_color()

func _process(_delta):
	if move and tween == null:
		transition_duration = leg_area.position.distance_to(Vector2(move_distance, 0)) / move_speed
		tween = create_tween().set_trans(transition_type)
		tween.tween_property(leg_area, "position:x", move_distance, transition_duration).finished.connect(
			func() -> void:
				tween.kill()
				tween = null
				move_distance *= -1
		)
"""
	if Input.is_action_just_pressed("accept"):
		move = not move
		if tween != null:
			tween.kill()
			tween = null
		update_leg_color()
"""

func update_leg_color():
	if move:
		leg_area.modulate = Color.YELLOW
	else:
		leg_area.modulate = Color.WHITE

func _on_leg_area_entered(area):
	if area.is_in_group("bullet"):
		area.queue_free()
		move = not move
		if tween != null:
			tween.kill()
			tween = null
		update_leg_color()

func _on_leg_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack)
