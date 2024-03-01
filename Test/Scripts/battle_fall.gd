extends Control

var main: Node2D = preload("res://Scenes/main.tscn").instantiate()
var main_player: CharacterBody2D = main.get_node("Player")
var main_player_color: Color = main_player.SOUL_COLOR[main_player.soul]
var main_player_origin: Vector2 = main_player.global_position
var main_player_scale: Vector2 = main_player.global_scale
var battle_fall: bool = false

@onready var soul: Sprite2D = $Soul

func _ready():
	print(main_player_origin)
	main = null
	main_player = null
	soul.self_modulate = main_player_color

func _process(_delta):
	if Input.is_action_just_pressed("accept") and not battle_fall:
		battle_fall = true
		
		soul.show()
		await Transition.blink(self, 2)
		
		var battle_fall_sound_length: float = Audio.play_sound_and_return_length("battlefall")
		
		create_tween().tween_property(soul, "global_position", main_player_origin, battle_fall_sound_length)
		create_tween().tween_property(soul, "global_scale", main_player_scale, battle_fall_sound_length)
		await time.sleep(battle_fall_sound_length)
		
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
