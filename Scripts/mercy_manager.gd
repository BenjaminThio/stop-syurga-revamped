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
@onready var player_animated_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var villian_sprite: AnimatedSprite2D = villian.get_child(0)
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
				[
					[
						"You apologized, but he refused it...",
						"It seems like this is not the only way to convince him."
					],
					[
						"你道歉，可是他拒绝了。。。",
						"看来这不是唯一能说服他的方法。"
					],
					[
						"尔道歉，然彼拒之。。。",
						"观之，此非独说服彼之法。"
					],
					[
						"Kamu meminta maaf, tetapi dia menolaknya.",
						"Kelihatannya ini bukan caranya untuk memujuk dia."
					],
					[
						"あなたは謝罪しましたが、彼はそれを拒否しました。。。",
						"彼を説得する唯一の方法ではないようです。"
					]
				][db.data.settings.language]
			])
	elif option == OPTION.FLEE:
		var player_global_position: Vector2 = player.global_position
		var flee_animated_sprite: AnimatedSprite2D = flee_animated_sprite_scene.instantiate()
		
		#owner.remove_child(player)
		#battlefield.add_child(player)
		player.global_position = player_global_position
		State.set_state(State.MAIN_STATE.FLEE)
		flee_animated_sprite.self_modulate = player.SOUL_COLOR[player.soul]
		
		player.add_child(flee_animated_sprite)
		
		if player.soul == player.SOUL.JUSTICE:
			var rotate_sound_length: float = Audio.play_sound_and_return_length("rotate")
			
			await create_tween().tween_property(player, "rotation_degrees", 0, rotate_sound_length).finished
			
			player.ghost_effect()
			Audio.play_sound("create")
			
			await time.sleep(0.5)
		
		var slidewhist_sound_length: float = Audio.play_sound_and_return_length("slidewhist")
		
		await create_tween().tween_property(flee_animated_sprite, "offset:y", 4, slidewhist_sound_length).finished
		
		flee_animated_sprite.play("flee")
		
		await time.sleep(ModifiedSpriteFrames.get_frame_absolute_duration(flee_animated_sprite))
		
		var escape_sound_length: float = Audio.play_sound_and_return_length("escape")
		
		await create_tween().tween_property(player, "global_position:x", -ModifiedSpriteFrames.get_frame(player_animated_sprite).get_width(), escape_sound_length).finished
		
		flee_animated_sprite.stop()
		Transition.fade_in(canvas, func() -> void: get_tree().change_scene_to_file("res://Scenes/main_manu.tscn"))
