extends Node2D

const DEFAULT_SPEECH_GAP_TIME: float = 0.03

var contents: Array = []:
	get:
		return contents
	set(value):
		#if get_stack()[1].source == get_script().get_path():
			contents = value
			State.add_substate_to_queue(State.SUBSTATE.SPEECH)
		#else:
		#	Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var skipable: bool = false
var upcoming_event: Callable = Callable()
var speech_gap_time: float = DEFAULT_SPEECH_GAP_TIME

@onready var bubble: NinePatchRect = $Bubble
@onready var label: Label = $Label
@onready var speech_audio_player: AudioStreamPlayer = $SpeechAudioPlayer
@onready var label_original_size: Vector2 = label.size
@onready var actions: Node2D = get_tree().get_first_node_in_group("actions")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var villian_speech_bubble: Node2D = villian.get_node("Speech")
@onready var villian_sprite: AnimatedSprite2D = villian.get_node("AnimatedSprite2D")
@onready var villian_vaporize_particles: GPUParticles2D = villian_sprite.get_node("VaporizeParticles")
@onready var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
@onready var stats: HBoxContainer = get_tree().get_first_node_in_group("stats")
@onready var health_bar: ProgressBar = get_tree().get_first_node_in_group("health_bar")

func _process(_delta) -> void:
	if State.current_substate == State.SUBSTATE.SPEECH:
		if Input.is_action_just_pressed("accept") and skipable:
			label.text = ""
			generate_speech()

func generate_speech() -> void:
	skipable = false
	if contents.size() > 0:
		villian.set_rotate(false)
		villian.animated_sprite.rotation_degrees = 0 
		await say_content(contents[0])
		contents.pop_front()
		skipable = true
	elif contents.size() == 0:
		State.substate_completed()
		if State.current_substate != null:
			State.complete_on_queue_substate()
		elif State.current_substate == null:
			if villian.health > 0:
				hide()
				actions.reset()
				villian.set_rotate(true)
				if not upcoming_event.is_null():
					upcoming_event.call()
					upcoming_event = Callable()
			elif villian.health == 0:
				var previous_level: int = db.get_player_level()
				
				villian_speech_bubble.hide()
				villian_vaporize_particles.emitting = true
				villian_vaporize_particles.one_shot = true
				create_tween().tween_property(villian_sprite, "self_modulate:a", 0, villian_vaporize_particles.lifetime / villian_vaporize_particles.speed_scale)
				Audio.play_sound("vaporized")
				db.data.player.exp += villian.reward.exp
				db.data.player.gold += villian.reward.gold
				db.save_data()
				description_label.set_statements([
					[
						[
							"YOU WIN!",
							"You earned {exp} exp and {gold} gold.".format({exp = villian.reward.exp, gold = villian.reward.gold})
						],
						[
							"你赢了！",
							"你获得{exp}经验值和{gold}金币。".format({exp = villian.reward.exp, gold = villian.reward.gold})
						],
						[
							"尔获胜！",
							"尔得{exp}經驗值及{gold}金幣。".format({exp = villian.reward.exp, gold = villian.reward.gold})
						],
						[
							"KAMU MENANG!",
							"Kamu telah mendapat {exp} exp dan {gold} syiling emas.".format({exp = villian.reward.exp, gold = villian.reward.gold})
						],
						[
							"勝ちました！",
							"あなたは{exp}の経験値と{gold}のゴールドを獲得しました。".format({exp = villian.reward.exp, gold = villian.reward.gold})
						]
					][db.data.settings.language]
				])
				if db.get_player_level() > previous_level:
					description_label.statements[0].append([
						"Your LEVEL increased.",
						"你的等级提升了。",
						"尔之品级升華矣。",
						"TAHAP kamu meningkat.",
						"レベルが上がりました。"
					][db.data.settings.language])
					db.level_define_all()
					stats.update_level()
					health_bar.update_health_bar()
					Audio.play_sound("levelup")

func say_content(speech_content: String) -> void:
	for character in speech_content:
		label.text += character
		if speech_gap_time == DEFAULT_SPEECH_GAP_TIME:
			if not speech_audio_player.playing and os.is_alpha(character):
				speech_audio_player.play()
			elif speech_audio_player.playing and not os.is_alpha(character):
				speech_audio_player.stop()
		else:
			if os.is_alpha(character):
				Audio.play_sound("txt_yifan")
		await time.sleep(speech_gap_time)
	if speech_gap_time == DEFAULT_SPEECH_GAP_TIME and speech_audio_player.playing:
		speech_audio_player.stop()

func set_contents(values: Array, delay_time: float = 0):
	if delay_time <= 0:
		speech_gap_time = 0.03
	elif delay_time > 0:
		speech_gap_time = delay_time
	
	contents = values

func _on_label_resized() -> void:
	bubble.size += label.size - label_original_size
	label_original_size = label.size
