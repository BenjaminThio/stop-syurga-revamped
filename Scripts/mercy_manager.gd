extends AnimatedSprite2D

enum OPTION {
	SPARE,
	FLEE
}
var flee_animated_sprite_scene: PackedScene = preload("res://Instances/flee.tscn")

@onready var translated_options: PackedStringArray = [
	OPTION.keys(),
	[
		"饶恕",
		"逃离"
	],
	[
		"寬恕",
		"脱离"
	],
	[
		"Mengampuni",
		"Melarikan Diri"
	],
	[
		"許す",
		"逃げる"
	]
][db.data.settings.language]
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var villian_sprite: Sprite2D = villian.get_child(0)
@onready var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")
@onready var canvas: Control = get_tree().get_first_node_in_group("canvas")
@onready var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
@onready var actions: Node2D = get_tree().get_first_node_in_group("actions")

func select_option(option: int) -> void:
	actions.get_child(actions.action_index).frame = 0
	actions.reset()
	if option == OPTION.SPARE:
		if villian.spareable:
			State.add_substate_to_queue(State.SUBSTATE.SPARE)
			villian.set_rotate(false)
			villian_sprite.rotation_degrees = 0
			villian_sprite.self_modulate.a /= 2
			owner.background_music_player.stop()
			Audio.play_sound("vaporized")
			
			await time.sleep(2, func() -> void: Transition.fade_in(canvas, func(): get_tree().change_scene_to_file("res://Scenes/main_manu.tscn")))
		else:
			var menu: VBoxContainer = get_tree().get_first_node_in_group("menu")
			
			player.hide()
			menu.queue_free()
			description_label.set_statements([
				"You apologized, but he refused it...",
				"It seems like this is not the only way to influence him."
			])
	elif option == OPTION.FLEE:
		var player_global_position: Vector2 = player.global_position
		var flee_animated_sprite: AnimatedSprite2D = flee_animated_sprite_scene.instantiate()
		
		#owner.remove_child(player)
		#battlefield.add_child(player)
		player.global_position = player_global_position
		State.set_state(State.MAIN_STATE.FLEE)
		flee_animated_sprite.self_modulate = player.soul
		
		player.add_child(flee_animated_sprite)
		
		create_tween().tween_property(flee_animated_sprite, "offset:y", 4, 0.5)
		Audio.play_sound("slidewhist")
		
		await time.sleep(0.5)
		
		flee_animated_sprite.play("flee")
		
		await time.sleep(ModifiedSpriteFrames.get_frame_absolute_duration(flee_animated_sprite))
		
		create_tween().tween_property(player, "global_position:x", -10, 2)
		Audio.play_sound("escape")
		
		await time.sleep(2)
		
		flee_animated_sprite.stop()
		Transition.fade_in(canvas, func() -> void: get_tree().change_scene_to_file("res://Scenes/main_manu.tscn"))
