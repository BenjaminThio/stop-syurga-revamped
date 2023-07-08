extends Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var vaporize_particles: GPUParticles2D = $Sprite/VaporizeParticles

func _ready():
	vaporize_particles.emitting = false
	await time.sleep(2)
	vaporize_particles.emitting = true
	vaporize_particles.one_shot = true
	create_tween().tween_property(sprite, "self_modulate:a", 0, vaporize_particles.lifetime / vaporize_particles.speed_scale)
