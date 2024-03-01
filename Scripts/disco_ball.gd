extends Area2D

const LIGHT_SPAWNPOINT_ROTATE_DEGREES: float = 72.0 #360.0 / 5.0 #const LIGHT_SPAWNPOINT_ROTATE_DEGREES: int = 72
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD #Tween.TransitionType.TRANS_SINE
@export var light_spawnpoint_rotate_speed: int = 130
@export var attack_pause_duration: float = 0.3
@export var difficulty: int = 1
@export var damage_multiplier: int = 2
@onready var disco_ball_animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var light_spawnpoint: Node2D = $LightSpawnpoint
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")
var light_spawnpoint_rotating: bool = false

func _process(_delta):
	if not light_spawnpoint_rotating:
		var light_spawnpoint_rotate_duration: float = LIGHT_SPAWNPOINT_ROTATE_DEGREES / light_spawnpoint_rotate_speed
		var tween: Tween = create_tween()
		
		light_spawnpoint_rotating = true
		await tween.set_trans(transition_type).tween_property(light_spawnpoint, "rotation_degrees", light_spawnpoint.rotation_degrees + LIGHT_SPAWNPOINT_ROTATE_DEGREES, light_spawnpoint_rotate_duration).finished
		await time.sleep(attack_pause_duration)
		light_spawnpoint_rotating = false

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		var blink_sound_length: float = Audio.play_sound_and_return_length("blink")
		
		area.queue_free()
		for light in light_spawnpoint.get_children():
			if light.attack_type == light.ATTACK_TYPE.WHITE_ATTACK:
				light.attack_type = light.original_attack_type
			elif light.attack_type == light.ATTACK_TYPE.LIGHT_BLUE_ATTACK:
				light.attack_type = light.ATTACK_TYPE.WHITE_ATTACK
		disco_ball_animated_sprite.frame = 1
		
		await time.sleep(blink_sound_length)
		
		disco_ball_animated_sprite.frame = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * damage_multiplier)

func _on_light_detection_area_entered(area):
	if area.is_in_group("light"):
		area.hide()
		area.attack_type = randi_range(0, difficulty)

func _on_light_detection_area_exited(area):
	if area.is_in_group("light"):
		area.show()
