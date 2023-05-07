extends Node2D

const SPEED: int = 100
var health: int = 34000
var activate_shield = false
var rotate: bool = true

var damage: int
var defence: int

@onready var sprite: Sprite2D = get_child(0)
@onready var shield: Sprite2D = sprite.get_child(0)
@onready var health_bar: ProgressBar = $"Health Bar"

func _ready() -> void:
	health_bar.max_value = health
	update_health_bar(false)

func _process(delta) -> void:
	if rotate:
		sprite.rotation_degrees += PI * delta * SPEED
		shield.rotation_degrees += PI * delta * (-SPEED * 1.5)
	if sprite.rotation_degrees >= 360:
		sprite.rotation_degrees -= 360

func set_rotate(boolean: bool) -> void:
	rotate = boolean

func deal_damage(damage_value: int) -> void:
	if damage_value < 0:
		var error: String = "The negative damage value is not acceptable."
		printerr(error)
		push_error(error)
		return
	
	if health - damage_value >= 0:
		health -= int(damage_value)
	else:
		health = 0
	update_health_bar()

func update_health_bar(require_tween: bool = true) -> void:
	if (require_tween):
		create_tween().tween_property(health_bar, "value", health, 0.7)
	else:
		health_bar.value = health

var id: int = 0
var shield_activate_time: float = 0.5
@export var passive_skill_duration: float = 2.0

func _on_villian_shield_area_entered(area: Area2D) -> void:
	id += 1
	var local_id: int = id
	
	area.queue_free()
	create_tween().tween_property(shield, "self_modulate:a", 1, shield_activate_time)
	await time.sleep(passive_skill_duration)
	
	if local_id != id:
		return
	
	var shield_deactivation_blink_times: int = 20
	var weaken_shield: bool = false
	var blink_counter: int = 0
	var blink_transition_duration: float = shield_activate_time
	var blink_transition_duration_reduction: float = blink_transition_duration * 0.2 # 20% from blink_transition_duration
	var min_blink_transition_duration: float = blink_transition_duration * 0.4 # 40% from blink_transition_duration
	
	for _i in range(shield_deactivation_blink_times):
		var tween: Tween = create_tween()
		if weaken_shield:
			tween.tween_property(shield, "self_modulate:a", 0, blink_transition_duration)
		else:
			tween.tween_property(shield, "self_modulate:a", 1, blink_transition_duration)
		blink_counter += 1
		if blink_counter % 2 == 0 and blink_transition_duration - blink_transition_duration_reduction > min_blink_transition_duration:
			blink_transition_duration -= blink_transition_duration_reduction
		weaken_shield = not weaken_shield
		await time.sleep(blink_transition_duration)
		if local_id != id:
			return

func shake(target: Node2D = get_child(0), times: int = 15, default_delay_time: float = 0.01, fixed_delay_time: bool = false) -> void:
	var offset_sign: bool = false
	var delay_time: float = default_delay_time
	var shake_range: Array = range(times, 0, -1)
	
	for shake_index in shake_range:
		target.position.x = shake_index * ((int(offset_sign) * 2) - 1) #[-1, 1][int(offset_sign)]
		offset_sign = not offset_sign
		if not fixed_delay_time:
			delay_time = default_delay_time * shake_range[shake_index - 1]
		await time.sleep(delay_time)
	target.position.x = 0

var attacks_path: String = "res://Instances/Attacks/"
var attacks: Array[String] = os.listdir(attacks_path)

func attack() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	var attack_move = load(attacks_path + random.choice(attacks)).instantiate()
	var attack_animation: AnimationPlayer = attack_move.get_child(attack_move.get_child_count() - 1)
	var actions: Node2D = get_tree().get_first_node_in_group("actions")
	
	player.change_form(player.SOUL.BLUE)
	
	await time.sleep(1)
	
	battlefield.add_child(attack_move)
	
	await time.sleep(attack_animation.get_current_animation_length())
	
	attack_move.queue_free()
	
	State.change_state(State.TAKING_ACTION)
	
	actions.take_action(true)
	
"""
@onready var villian_sprite: Sprite2D = get_child(0)
@onready var origin_x: float = villian_sprite.position.x

func shake(times: int = 15, default_delay_time: float = 0.01, fixed_delay_time: bool = false):
	var offset_sign: bool = false
	var delay_time: float = default_delay_time
	var shake_range: Array = range(times, 0, -1)
	
	for shake_index in shake_range:
		villian_sprite.position.x = origin_x + (shake_index * ((int(offset_sign) * 2) - 1)) #[-1, 1][int(offset_sign)]
		offset_sign = not offset_sign
		if not fixed_delay_time:
			delay_time = default_delay_time * shake_range[shake_index - 1]
		await time.sleep(delay_time)
	villian_sprite.position.x = origin_x
"""
