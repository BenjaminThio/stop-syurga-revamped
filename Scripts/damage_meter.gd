extends Node2D

var speed: float = 366
var distance: float = 0
var transition_time: float = 0
var front_meter_range: float = 50
var back_meter_range: float = 50
var max_damage: float = 1700
var min_damage: float = max_damage * 0.1
var has_damaged: bool = false

var tween: Tween = null

@onready var slider: AnimatedSprite2D = $Slider
@onready var starting_point: Marker2D = $Background/Start
@onready var end_point: Marker2D = $Background/End
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer

func _ready() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	var box: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
	player.hide()
	create_tween().tween_property(box, "size:x", 768, 0.5)
	create_tween().tween_property(box, "position:x", 192, 0.5)
	animation_player.play("damage_meter_appear")
	slider.global_position.x = starting_point.global_position.x
	distance = round(end_point.global_position.x - slider.global_position.x)
	transition_time = distance / speed

func _process(_delta) -> void:
	if Input.is_action_just_pressed("accept") and tween != null and not has_damaged and slider != null:
		var villian: Node2D = get_tree().get_first_node_in_group("villian")
		var villian_sprite: Node2D = villian.get_child(0)
		var villian_health_bar: ProgressBar = villian.get_child(1)
		var slay_animation: Node = preload("res://Instances/weapon.tscn").instantiate()
		
		has_damaged = true
		
		tween.kill()
		slider.play("slider_flashing")
		villian_health_bar.show()
		villian.deal_damage(get_calculated_damage())
		villian.set_rotate(false)
		
		villian.add_child(slay_animation)
		slay_animation.global_position = villian.global_position
		
		villian_sprite.rotation_degrees = 0
		villian.shake()
		await time.sleep(1)
		villian.set_rotate(true)
		villian_health_bar.hide()
		slider.stop()
		await enemy_turn()

func slide_slider() -> void:
	distance = round(end_point.global_position.x - slider.global_position.x)
	transition_time = distance / speed
	tween = create_tween()
	tween.tween_property(slider, "global_position:x", end_point.global_position.x, transition_time)
	tween.finished.connect(enemy_turn)

func enemy_turn() -> void:
	var action_buttons: Node2D = get_tree().get_first_node_in_group("actions")
	
	action_buttons.get_child(action_buttons.action_index).frame = 0
	State.change_state(State.COMBATING)
	slider.queue_free()
	animation_player.play_backwards("damage_meter_appear")
	await time.sleep(animation_player.get_current_animation_length())
	action_buttons.reset()
	self.queue_free()

func get_calculated_damage() -> float:
	var damage: float = 0
	var slider_value = (slider.global_position.x - starting_point.global_position.x) / (end_point.global_position.x - starting_point.global_position.x) * 100
	
	if slider_value <= front_meter_range:
		damage = slider_value / front_meter_range * max_damage
	elif slider_value > back_meter_range:
		damage = (front_meter_range + back_meter_range - slider_value) / back_meter_range * max_damage
		
	if damage < min_damage:
		damage = min_damage
	
	return damage
