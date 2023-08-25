extends Marker2D

@export var spear_visibility_toggle_duration: float = 0.3
@export var swirl_rotation_degrees: int = 270
@export var rotational_transition_type: Tween.TransitionType = Tween.TRANS_QUINT
@export var movement_transition_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
@export var rotate_duration: float = 5.0
@export var movement_duration: float = 3.5
@export var spear_invalid_delay_duration: float = 2.3

func _ready():
	var tween: Tween = create_tween()
	
	modulate.a = 0
	tween.parallel().tween_property(self, "modulate:a", 1, spear_visibility_toggle_duration)
	tween.parallel().set_trans(rotational_transition_type).set_ease(ease_type).tween_property(self, "rotation_degrees", swirl_rotation_degrees, rotate_duration)
	for white_spear in get_children():
		create_tween().set_trans(movement_transition_type).set_ease(ease_type).tween_property(white_spear, "position", Vector2.ZERO, movement_duration)
	
	await time.sleep(spear_invalid_delay_duration)
	
	for white_spear in get_children():
		white_spear.monitoring = false
	
	create_tween().tween_property(self, "modulate:a", 0, spear_visibility_toggle_duration).finished.connect(queue_free)
	
