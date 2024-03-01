extends Area2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD
@export var direction: DIRECTION = DIRECTION.RIGHT
@export var transition_duration: float = 2.0
@export var move_distance: int = 500
@export var static_duration: float = 0.5
@export var rotate_speed: int = 100
@export var damage_multiplier: int = 2
@onready var sprite: Sprite2D = $Sprite
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")

func _ready():
	await time.sleep(0.1)
	create_tween().set_trans(transition_type).tween_property(self, "position:x", position.x + (move_distance * [-1, 1][direction]), transition_duration).finished.connect(
		func() -> void:
			await time.sleep(static_duration)
			create_tween().set_trans(transition_type).tween_property(self, "global_position:x", [get_viewport_rect().size.x + (sprite.get_rect().size.x / 2), -sprite.get_rect().size.x / 2][direction], transition_duration + 1).finished.connect(queue_free)
	)

func _process(delta):
	rotation_degrees += PI * rotate_speed * delta
	if rotation_degrees >= 360:
		rotation_degrees = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * damage_multiplier)
