extends Node2D

var eating: bool = false
var super_ring_disappear_time: float = 0.3
var chew_times: int = 5
@onready var mouth: Sprite2D = $Face/Mouth
@onready var mouth_detection_area: Area2D = $Face/Mouth/DetectionArea
@onready var mouth_animation_player: AnimationPlayer = $Face/AnimationPlayer
@onready var residue_particles: GPUParticles2D = $Face/ResidueParticles
@onready var right_hand: AnimatedSprite2D = $RightHand
@onready var right_hand_animation_player: AnimationPlayer = $RightHand/AnimationPlayer
@onready var snack_package_animation_player: AnimationPlayer = $Snack/Package/AnimationPlayer
@onready var half_ring_particles: GPUParticles2D = $Snack/HalfRingParticles
@onready var full_ring_particles: GPUParticles2D = $Snack/FullRingParticles
@onready var eating_sound_effect: AudioStreamPlayer = $EatingSoundEffect

func _on_snack_package_area_entered(area) -> void:
	if area.get_parent() == right_hand and right_hand_animation_player.is_playing() and right_hand_animation_player.current_animation == "take_super_ring":
		snack_package_animation_player.play("snack_package_bouncing")
		half_ring_particles.emitting = true
		full_ring_particles.emitting = true

func _on_snack_package_area_exited(area) -> void:
	if area.get_parent() == right_hand:
		snack_package_animation_player.stop()
		half_ring_particles.emitting = false
		full_ring_particles.emitting = false

func _on_mouth_area_entered(area) -> void:
	if area.get_parent() == right_hand and not eating:
		eating = true
		mouth_animation_player.play("big_bite")
		await time.sleep(mouth_animation_player.current_animation_length - super_ring_disappear_time)
		right_hand.frame = 0
		await time.sleep(super_ring_disappear_time)
		eating_sound_effect.play()
		for _i in range(chew_times):
			mouth_animation_player.play("eating")
			await time.sleep(mouth_animation_player.current_animation_length)
		mouth_animation_player.stop()
		eating_sound_effect.stop()
		right_hand_animation_player.play("hide_hand")
		await time.sleep(right_hand_animation_player.current_animation_length + 1.0)
		right_hand_animation_player.play("take_super_ring")
		eating = false

func emit_residue_particles() -> void:
	residue_particles.global_position = mouth.global_position
	residue_particles.emitting = true
	await time.sleep(mouth_animation_player.current_animation_length - mouth_animation_player.current_animation_position)
	residue_particles.emitting = false
