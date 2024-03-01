extends Area2D

var activated: bool = false
var activate_position: Vector2 = Vector2.ZERO
@export var prebomb_times: int = 2
@export var laser_disappear_duration: float = 0.3
@export var physical_damage_multiplier: int = 2
@export var magic_damage_multiplier: int = 3
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var horizontal_laser: Area2D = $HorizontalLaser
@onready var vertical_laser: Area2D = $VerticalLaser

func _process(_delta):
	if activated:
		global_position = activate_position

func _on_area_entered(area):
	if area.is_in_group("bullet") and not activated:
		area.queue_free()
		
		activate_position = global_position
		activated = true
		
		for _i in range(prebomb_times):
			var prebomb_sound_length: float = Audio.play_sound_and_return_length("prebomb")
			
			animated_sprite.frame = 1
			
			await time.sleep(prebomb_sound_length / 2)
			
			animated_sprite.frame = 0
			
			await time.sleep(prebomb_sound_length / 2)
		
		monitoring = false
		animated_sprite.hide()
		
		horizontal_laser.monitoring = true
		horizontal_laser.show()
		vertical_laser.monitoring = true
		vertical_laser.show()
		
		var tween: Tween = create_tween()
		
		tween.tween_property(horizontal_laser, "modulate:a", 0, laser_disappear_duration)
		tween.parallel().tween_property(vertical_laser, "modulate:a", 0, laser_disappear_duration).finished.connect(queue_free)
		Audio.play_sound("bomb")

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * physical_damage_multiplier)

func _on_laser_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * magic_damage_multiplier)
