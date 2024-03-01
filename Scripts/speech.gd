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
var is_transition_disabled: bool = false

@onready var bubble: NinePatchRect = $Bubble
@onready var lines_container: VBoxContainer = $LinesContainer
@onready var speech_audio_player: AudioStreamPlayer = $SpeechAudioPlayer
@onready var lines_container_original_size: Vector2 = lines_container.size
@onready var actions: Node2D = get_tree().get_first_node_in_group("actions")
@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")
@onready var villain_speech_bubble: Node2D = villain.get_node("Speech")
@onready var villain_sprite: AnimatedSprite2D = villain.get_node("AnimatedSprite2D")
@onready var villain_vaporize_particles: GPUParticles2D = villain_sprite.get_node("VaporizeParticles")
@onready var description_manager: Node2D = get_tree().get_first_node_in_group("description_manager")
@onready var stats: HBoxContainer = get_tree().get_first_node_in_group("stats")
@onready var health_bar: ProgressBar = get_tree().get_first_node_in_group("health_bar")

func _process(_delta) -> void:
	if State.current_substate == State.SUBSTATE.SPEECH:
		if Input.is_action_just_pressed("accept") and skipable:
			lines_container.text = ""
			generate_speech()
		elif Input.is_action_just_pressed("cancel"):
			is_transition_disabled = true

func generate_speech() -> void:
	skipable = false
	if contents.size() > 0:
		villain.is_rotating = false
		villain.animated_sprite.rotation_degrees = 0 
		await say_content(contents[0])
		contents.pop_front()
		skipable = true
	elif contents.size() == 0:
		State.substate_completed()
		if State.current_substate != null:
			State.complete_on_queue_substate()
		elif State.current_substate == null:
			if villain.health > 0:
				hide()
				actions.reset()
				villain.is_rotating = true
				if not upcoming_event.is_null():
					upcoming_event.call()
					upcoming_event = Callable()
			elif villain.health == 0:
				var previous_level: int = db.get_player_level()
				
				villain_speech_bubble.hide()
				villain_vaporize_particles.emitting = true
				villain_vaporize_particles.one_shot = true
				create_tween().tween_property(villain_sprite, "self_modulate:a", 0, villain_vaporize_particles.lifetime / villain_vaporize_particles.speed_scale)
				Audio.play_sound("vaporized")
				description_manager.set_statements([[[
					"YOU WIN!",
					"你赢了！",
					"尔获胜！",
					"KAMU MENANG!",
					"勝ちました！"
				][db.data.settings.language]]])
				if Global.loop_attack_index == null:
					description_manager.statements[0].append([
						"You earned {exp} exp and {gold} gold.".format({exp = villain.reward.exp, gold = villain.reward.gold}),
						"你获得{exp}经验值和{gold}金币。".format({exp = villain.reward.exp, gold = villain.reward.gold}),
						"尔得{exp}經驗值及{gold}金幣。".format({exp = villain.reward.exp, gold = villain.reward.gold}),
						"Kamu telah mendapat {exp} exp dan {gold} syiling emas.".format({exp = villain.reward.exp, gold = villain.reward.gold}),
						"あなたは{exp}の経験値と{gold}のゴールドを獲得しました。".format({exp = villain.reward.exp, gold = villain.reward.gold})
					][db.data.settings.language])
					db.data.player.exp += villain.reward.exp
					db.data.player.gold += villain.reward.gold
					db.save_data()
				if db.get_player_level() > previous_level:
					description_manager.statements[0].append([
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
	var font_width: int
	
	is_transition_disabled = false
	
	if db.data.settings.language in [db.LANGUAGE.CHINESE, db.LANGUAGE.CLASSICAL_CHINESE, db.LANGUAGE.JAPANESE]:
		font_width = lines_container.font_size
	else:
		font_width = 11
	
	for character in Autowrap.smart_autowrap(speech_content, font_width, lines_container):
		lines_container.text += character
		if speech_gap_time == DEFAULT_SPEECH_GAP_TIME:
			if not speech_audio_player.playing and os.is_alpha(character):
				speech_audio_player.play()
			elif speech_audio_player.playing and not os.is_alpha(character):
				speech_audio_player.stop()
		else:
			if os.is_alpha(character) and not is_transition_disabled:
				Audio.play_sound("txt_yifan")
		
		if character != "\n" and not is_transition_disabled:
			await time.sleep(speech_gap_time)
		else:
			continue
	if speech_gap_time == DEFAULT_SPEECH_GAP_TIME and speech_audio_player.playing:
		speech_audio_player.stop()

func set_contents(values: Array, delay_time: float = 0):
	if delay_time <= 0:
		speech_gap_time = 0.03
	elif delay_time > 0:
		speech_gap_time = delay_time
	
	contents = values

func _on_lines_container_resized() -> void:
	bubble.size += lines_container.size - lines_container_original_size
	lines_container_original_size = lines_container.size
