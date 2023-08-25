extends Control

var is_fading_out: bool = false

@onready var image: TextureRect = $Image
@onready var text_label: RichTextLabel = $Text
@onready var typing_sound_effect: AudioStreamPlayer = $TypingSoundEffect
@onready var background_music: AudioStreamPlayer = $BackgroundMusic

@export var image_transition_time: float = 0.5
@export var image_invisible_time: float = 1.5
@export var label_reset_time: float = 0.5
@export var music_fade_out_time: float = 10.0

var storylines: Array[PackedStringArray] = [
	[
		"Once upon a time, there lived a man named Yi Fan.",
		"很久很久以前，有一个叫奕凡的家伙。",
		"昔日遥远，有一人名奕凡。",
		"Pada suatu masa dahulu, terdapat seorang lelaki bernama Yi Fan.",
		"昔々、ある男性が住んでいました。その男性の名前は奕凡でした。"
	],
	[
		"Yi Fan himself was a gay, and he developed romantic feelings for his close male friend, Zen Thye.",
		"奕凡本身是个男同，而且他还喜欢上了他的好兄弟—程泰。",
		"奕凡本身性倾向同性，且对其亲密友人程泰心生爱慕。",
		"Yi Fan sendiri adalah seorang homoseksual, dan dia cinta akan sahabat karibnya, Zen Thye.",
		"奕凡は男同性愛者であり、さらに彼は親友である程泰に恋心を抱いています。"
	],
	[
		"After a period of observation, Yi Fan discovered that Zen Thye also shared the same sexual orientation. As a result, they quickly became a couple.",
		"经过一番观察， 奕凡发现程泰也是是个男同。 于是，他们很快就在一起了。",
		"观察片刻，奕凡见程泰亦为同性之倾向。遂二人亦速成一对。",
		"Setelah pemerhatian dalam suatu tempoh, Yi Fan mengetahui bahawa Zen Thye juga seorang homoseksual. Maka, mereka menjadi pasangan tidak lama selepas itu.",
		"綿密な観察の後、奕凡は程泰も同性愛者であることに気付きました。その結果、彼らは迅速にカップルとなりました。"
	],
	[
		"Although Yi Fan never cares how others judge their relationship,",
		"尽管奕凡从不在意别人对他们之间关系的看法，",
		"奕凡纵然不顾他人观瞻，",
		"Walaupun Yi Fan tidak mempedulikan pendapat orang lain mengenai hubungan mereka,",
		"奕凡は他らの関係について他人の見解を気にすることはなかったが、"
	],
	[
		"but the world proved to be harsh, societal discrimination pushed Zen Thye to the brink of mental collapse.",
		"但是世界是残酷的， 来自社会的歧视让程泰破防了。",
		"然斯世残酷，社会偏见使程泰心灵崩溃之境地。",
		"tetapi dunia ini kejam, diskriminasi sosial telah menyebabkan Zen Thye hampir terhanyut dalam kegelapan mental.",
		"しかし、世界は残酷であり、社会からの差別が程泰の精神を崩壊させました。"
	],
	[
		"One fateful day, Yi Fan uncovered Zen Thye's betrayal.",
		"一天， 奕凡发现程泰给自己带绿帽。",
		"一日，奕凡见程泰行背叛之事。",
		"Pada suatu hari yang takdirnya tertentu, Yi Fan terbongkar akan pengkhianatan Zen Thye.",
		"ある日、奕凡は程泰が浮気をしていることに気付きました。"
	],
	[
		"Initially, Yi Fan was overcome with unprecedented sorrow, but soon his love turned into hatred, and he resolved to seek revenge against Zen Thye.",
		"起初，奕凡只是感到前所未有的伤心，但很快，他因为爱生恨，决定对程泰进行报复。",
		"初时，奕凡感触前所未有之伤痛，然转瞬间，因爱生恨，决意报复程泰。",
		"Pada mulanya, Yi Fan diliputi kesedihan yang tiada tandingan, namun segera perasaan cintanya berubah menjadi kebencian, dan dia berazam untuk membalas dendam terhadap Zen Thye.",
		"最初、奕凡は前例のないほど傷心を感じただけでしたが、やがて彼は愛から憎しみが生まれ、程泰に対して復讐することを決意しました。"
	],
	[
		"So, how will Yi Fan navigate this challenging destiny?",
		"那么，奕凡将如面对这个坎坷的命运呢？",
		"然则，奕凡将如何应对此困境之命运？",
		"Bagaimanakah Yi Fan akan menempuh takdir yang penuh cabaran ini? ",
		"では、奕凡はこの困難な運命にどのように立ち向かうのでしょうか？"
	],
	[
		"No one knows, it appears that only time can unravel the truth.",
		"没有人知道，似乎只有时间能揭示一切。",
		"无人知晓，惟时间或能揭示一切。",
		"Tiada siapa yang tahu, nampaknya hanya masa yang dapat mendedahkan segala kebenaran.",
		"誰もが知ることはなく、おそらく全てを明らかにするのは時間のみでしょう。"
	]
]

func _ready() -> void:
	image.self_modulate.a = 0
	background_music.play()
	
	for storylineIndex in range(len(storylines)):
		image.texture = load("res://Sprites/Intro/intro{imageIndex}.png".format({"imageIndex": storylineIndex + 1}))
		create_tween().tween_property(image, "self_modulate:a", 1, image_transition_time)
		for character in storylines[storylineIndex][db.data.settings.language]:
			text_label.text += character
			if not typing_sound_effect.playing and os.is_alpha(character):
				typing_sound_effect.play()
			elif typing_sound_effect.playing and not os.is_alpha(character):
				typing_sound_effect.stop()
			await time.sleep(get_calculated_char_appear_gap_time())
		if typing_sound_effect.playing:
			typing_sound_effect.stop()
		await time.sleep(image_invisible_time)
		create_tween().tween_property(image, "self_modulate:a", 0, image_transition_time)
		await time.sleep(label_reset_time)
		text_label.text = ""
	
	await time.sleep(5)
	
	fade_out()

func _process(_delta):
	if Input.is_action_just_pressed("accept") and not is_fading_out:
		fade_out()

func get_calculated_char_appear_gap_time() -> float:
	var char_counter: int = 0
	var background_music_length : float = background_music.stream.get_length()
	
	for storyline in storylines:
		char_counter += len(storyline[db.data.settings.language])
	return (background_music_length - music_fade_out_time - ((image_invisible_time + label_reset_time) * storylines.size())) / char_counter

func fade_out(callable: Callable = func() -> void: get_tree().change_scene_to_file("res://Scenes/logo.tscn"), color: Color = Color.BLACK, duration: float = 1.0):
	var color_rect: ColorRect = ColorRect.new()
	
	is_fading_out = true
	color_rect.size = get_viewport_rect().size
	color_rect.self_modulate = color
	color_rect.self_modulate.a = 0
	add_child(color_rect)
	create_tween().tween_property(color_rect, "self_modulate:a", 1, duration)
	create_tween().tween_property(background_music, "volume_db", -10, duration)
	
	await time.sleep(duration, callable)
