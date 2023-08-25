extends Area2D

var vanished: bool = false
var vanish_position: Vector2
@export var max_scale: float = 2.0
@export var damage_multiplier: int = 2
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")

func _process(_delta):
	if vanished:
		global_position = vanish_position

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		area.queue_free()
		vanish()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villian.attack * damage_multiplier)

func vanish():
	var burst_sound_length: float = Audio.play_sound_and_return_length("burst")
	
	vanished = true
	vanish_position = global_position
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	create_tween().tween_property(self, "scale", Vector2(max_scale, max_scale), burst_sound_length)
	create_tween().tween_property(self, "modulate:a", 0, burst_sound_length).finished.connect(queue_free)
