extends AnimatedSprite2D

enum OPTION {
	CHECK,
	GREET,
	EXPLAIN,
	TEASE,
	HUG,
	CHANGE_MUSIC
}

var greet_counter: int = 0

@onready var translated_options: PackedStringArray = [
	OPTION.keys(),
	[
		"检查",
		"打招呼",
		"解释",
		"嘲笑",
		"拥抱",
		"更换音乐"
	],
	[
		"察视",
		"问好",
		"釋明",
		"譏笑",
		"擁抱",
		"換曲"
	],
	[
		"Menyemak",
		"Menyapa",
		"Menjelas",
		"mentertawakan",
		"Memeluk",
		"Menukar Musik"
	],
	[
		"チェックする",
		"挨拶",
		"説明する",
		"あざ笑う",
		"抱擁する",
		"音楽を変更する"
	]
][db.data.settings.language]

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var villian: Area2D = get_tree().get_first_node_in_group("villian")
@onready var description_label: RichTextLabel = get_tree().get_first_node_in_group("description_label")
@onready var speech: Node2D = get_tree().get_first_node_in_group("speech")
@onready var actions: Node2D = get_tree().get_first_node_in_group("actions")

func select_option(option: int) -> void:
	if option == OPTION.CHANGE_MUSIC:
		var file_dialog: FileDialog = FileDialog.new()
		
		owner.set_pause(true)
		owner.add_child(file_dialog)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.size = Vector2(450, 500)
		file_dialog.set_filters(["*ogg", "*wav", "*mp3"])
		file_dialog.canceled.connect(func() -> void: owner.set_pause(false))
		file_dialog.file_selected.connect(_on_file_selected)
		file_dialog.canceled.connect(_on_file_dialog_canceled)
		file_dialog.popup_centered()
	else:
		var menu: VBoxContainer = get_tree().get_first_node_in_group("menu")
		var villian_name: String = villian.enemy_name.to_upper() 
		
		player.hide()
		actions.get_child(actions.action_index).frame = 0
		actions.reset()
		menu.queue_free()
		if option == OPTION.CHECK:
			description_label.set_statements([
				[
					"{villian_name} {villian_attack} ATK {villian_defense} DEF".format({"villian_name": villian_name, "villian_attack": villian.attack, "villian_defense": villian.defense}), 
					"{villian_name} {villian_attack} 点攻击力 {villian_defense} 点防御力".format({"villian_name": villian_name, "villian_attack": villian.attack, "villian_defense": villian.defense}),
					"{villian_name} {villian_attack} 点攻击力 {villian_defense} 点防御力".format({"villian_name": villian_name, "villian_attack": villian.attack, "villian_defense": villian.defense}),
					"{villian_name} {villian_attack} ATK {villian_defense} DEF".format({"villian_name": villian_name, "villian_attack": villian.attack, "villian_defense": villian.defense}),
					"{villian_name} {villian_attack} ポイントの攻撃力 {villian_defense} ポイントの防御力".format({"villian_name": villian_name, "villian_attack": villian.attack, "villian_defense": villian.defense})
				][db.data.settings.language],
				[
					"You can sense the fury embedded within his smile.",
					"你可以感受到他微笑中蕴含的愤怒。",
					"尔能觉其微笑之中所藏之怒。",
					"Kamu dapat merasai kemarahan yang tersirat dalam senyumannya.",
					"彼の微笑みに怒りを感じることができる。"
				][db.data.settings.language]
			])
		elif option == OPTION.GREET:
			if greet_counter == 0:
				description_label.set_statements([
					[
						"You greet {villian_name} awkwardly...".format({"villian_name":  villian_name}),
						"你尴尬地向{villian_name}打招呼。。。".format({"villian_name":  villian_name}),
						"尔尴尬地向{villian_name}问好。。。".format({"villian_name":  villian_name}),
						"Kamu menyapa dengan {villian_name} secara kekok...".format({"villian_name":  villian_name}),
						"あなたは彼にぎこちなく挨拶する。。。".format({"villian_name":  villian_name})
					][db.data.settings.language],
					[
						"He thought that you were deliberately provoking him.",
						"他以为你在刻意激怒他。",
						"彼以为尔欲挑逗之。",
						"Dia ingat kamu sedang menghasutnya dengan sengaja。",
						"彼はあなたが彼を意図的に刺激しようとしていると思った。"
					][db.data.settings.language],
					[
						"{villian_name}'s ATTACK increased by 2!".format({"villian_name":  villian_name}),
						"{villian_name}的攻击力增加了2点!".format({"villian_name":  villian_name}),
						"{villian_name}之攻击力增加二点!".format({"villian_name":  villian_name}),
						"ATK {villian_name} meningkat sebanyak 2!".format({"villian_name":  villian_name}),
						"{villian_name}の攻撃力が2上昇しました！".format({"villian_name":  villian_name})
					][db.data.settings.language]
				])
				villian.attack += 2
			elif greet_counter >= 1:
				description_label.set_statements([
					[
						"You greet {villian_name} again...".format({"villian_name":  villian_name}),
						"你再次向{villian_name}打招呼。。。".format({"villian_name":  villian_name}),
						"尔复次向{villian_name}问好。。。".format({"villian_name":  villian_name}),
						"Kamu bertegur sapa dengan {villian_name} sekali lagi...".format({"villian_name":  villian_name}),
						"あなたは再び{villian_name}に挨拶する。。。".format({"villian_name":  villian_name})
					][db.data.settings.language]
				])
				if greet_counter == 1:
					description_label.statements.append(
						[
							"He ignores you, and nothing happens...",
							"他不鸟你，什么事都没有发生。。。",
							"彼忽尔尔者，无有所成。。。",
							"Dia tidak peduli kamu, dan tiada apa-apa yang berlaku.",
							"彼はあなたを無視し、何も起こりません。。。"
						][db.data.settings.language]
					)
				elif greet_counter > 1:
					description_label.statements.append([
						[
							"He started feeling puzzled by your actions.",
							"他开始对你的迷惑行为感到莫名其妙。",
							"彼始以尔之动作感困惑。",
							"Dia mula berasa bingung dengan tindakanmu.",
							"彼は君の行動に困惑し始めた。"
						][db.data.settings.language]
					])
			greet_counter += 1
		elif option == OPTION.EXPLAIN:
			description_label.set_statements([
				[
					"You try to explain the reasons for what you did to {villian_name} in the past...".format({"villian_name": villian_name}),
					"{villian_name} just don't give it a fuck!".format({"villian_name":  villian_name})
				],
				[
					"你试着为你以前的所作所为做出解释。。。",
					"{villian_name}没有要鸟你的意思。".format({"villian_name":  villian_name}),
				],
				[
					"尔欲解释尔何故在往昔以斯种为之。。。",
					"{villian_name}無視尔！".format({"villian_name":  villian_name}),
				],
				[
					"Kamu cuba menerangkan mengapa kamu melakukan hal itu kepadanya pada masa lalu...",
					"{villian_name} tidak peduli kamu!".format({"villian_name":  villian_name})
				],
				[
					"過去の彼に対してそれをなぜしたのか説明しようとする。。。",
					"{villian_name}はお前を無視する！".format({"villian_name":  villian_name})
				]
			][db.data.settings.language])
		elif option == OPTION.TEASE:
			description_label.set_statements([
				[
					"You tease {villian_name} for being a gay...".format({"villian_name":  villian_name}),
					"A wave of unpleasant memories from the past floods back.",
					"{villian_name}'s ATTACK increased by 7!".format({"villian_name":  villian_name})
				],
				[
					"你嘲笑{villian_name}是个同性恋。。。".format({"villian_name":  villian_name}),
					"过去一连串不开心的回忆涌上心头。",
					"{villian_name}的攻击力增加了7点!".format({"villian_name":  villian_name})
				],
				[
					"尔譏笑{villian_name}為一同性恋者".format({"villian_name":  villian_name}),
					"往昔之不愉快事悉复涌心头。",
					"{villian_name}之攻击力增加七点!".format({"villian_name":  villian_name})
				],
				[
					"Kamu mentertawakan {villian_name} sebagai seorang homoseksual".format({"villian_name":  villian_name}),
					"Kenangan yang sedih dari masa lepas membanjiri fikirannya.",
					"ATK {villian_name} meningkat sebanyak 7!".format({"villian_name":  villian_name})
				],
				[
					"君は{villian_name}をゲイと嘲笑する".format({"villian_name":  villian_name}),
					"過去の不愉快な思い出が甦ってきて、心に押し寄せる。",
					"{villian_name}の攻撃力が7上昇しました！".format({"villian_name":  villian_name})
				]
			][db.data.settings.language])
			villian.attack += 7
		elif option == OPTION.HUG:
			description_label.set_statements([
				[
					"You hug {villian_name} at the wrong time....".format({"villian_name":  villian_name}),
					"你在错的时间拥抱{villian_name}。。。".format({"villian_name":  villian_name}),
					"君于不当之时拥抱了{villian_name}。。。".format({"villian_name":  villian_name}),
					"Kamu memeluk {villian_name} pada waktu yang salah...".format({"villian_name":  villian_name}),
					"君は間違った時に{villian_name}を抱きしめた。。。".format({"villian_name":  villian_name})
				][db.data.settings.language],
				[
					"The developer of this game expresses that he doesn't know how to continue bullshitting already...",
					"本游戏的开发者表示他编不下去了。。。",
					"斯游戏之开发者表明已编无由可逐是剧情之陋矣。。。",
					"Pengaturcaraan permainan ini mengatakan bahawa dia tak tahu macam mana teruskan penulisan ceritanya yang tahi...",
					"このゲームの開発者は、もうこのくそつまらないストーリーをどう続ければいいのかわからないと述べています。。。"
				][db.data.settings.language]
			])
			speech.upcoming_event = func() -> void: State.set_state(State.MAIN_STATE.COMBATING)
			speech.set_contents([
				[
					"WTF? Are you kidding me?",
					"什么鬼？你在跟我开什么国际玩笑？",
					"何耶？尔竟敢戏弄吾？",
					"Apa? Adakah kamu sedang bergurau dengan saya?",
					"何だって？冗談で私をからかっているのか？"
				][db.data.settings.language]
			])

func _on_file_selected(path: String) -> void:
	var menu: VBoxContainer = get_tree().get_first_node_in_group("menu")
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	owner.play_audio(path)
	menu.has_made_decision()
	owner.set_pause(false)

func _on_file_dialog_canceled():
	pass
	#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
