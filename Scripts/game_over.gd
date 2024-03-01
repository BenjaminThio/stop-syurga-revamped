extends Control

@export var default_font: FontFile = preload("res://Fonts/8-BIT WONDER.TTF")

var on_queue: bool = false
var phases: int = 0

@onready var quotes: PackedStringArray = [
	[
		"The future depends on you!",
		"Don't lose hope!",
		"You cannot give up just yet..."
	],
	[
		"未来取决于你！",
		"不要失去希望！",
		"你还不能放弃。。。"
	],
	[
		"未來取決於尔！",
		"莫失所望！",
		"尔猶不可棄。。。"
	],
	[
		"Masa depan bergantung kepada kamu!",
		"Jangan kehilangan harapan!",
		"Kamu tidak boleh berputus asa lagi..."
	],
	[
		"未来はあなた次第です！",
		"希望を捨てるな！",
		"まだあきらめることはできない。。。"
	]
][db.data.settings.language]
@onready var main: Node2D = get_tree().get_root().get_node("Main")
@onready var game_over_label: Label = $Title
@onready var quote_manager: VBoxContainer = $ScrollContainer/LinesContainer

func _ready() -> void:
	game_over_label.text = [
		"Game\nOver",
		"游戏\n结束",
		"遊戲\n終止",
		"Permainan\nTamat",
		"ゲーム\nオーバー"
	][db.data.settings.language]
	game_over_label.self_modulate.a = 0
	quote_manager.text = ""
	main.background_music_player.volume_db = 0.0
	main.background_music_player.pitch_scale = 1.08
	game_over_label.add_theme_font_override("font", Global.get_font(default_font))
	
	main.play_audio("res://Musics/mus_game_over.ogg")
	
	on_queue = true
	create_tween().tween_property(game_over_label, "self_modulate:a", 1, 1.5)
	await time.sleep(1.5)
	on_queue = false
	
	var random_quote: String = random.choice(quotes)
	
	await asgore_say(random_quote)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("accept") and not on_queue:
		phases += 1
		quote_manager.text = ""
		if phases == 1:
			await asgore_say([
				"{name}!\nStay determined.".format({"name": db.data.player.name}),
				"{name}!\n保持决心。".format({"name": db.data.player.name}),
				"{name}!\n保持決心。".format({"name": db.data.player.name}),
				"{name}!\nMengekalkan keazamanmu.".format({"name": db.data.player.name}),
				"{name}!\n決心を持ち続けてください。".format({"name": db.data.player.name})
			][db.data.settings.language])
		elif phases == 2:
			on_queue = true
			await time.sleep(3)
			create_tween().tween_property(game_over_label, "self_modulate:a", 0, 1.5)
			create_tween().tween_property(main.background_music_player, "volume_db", -10, 1.5)
			await time.sleep(1.5)
			on_queue = false
			
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func asgore_say(quote: String) -> void:
	var font_width: int
	
	on_queue = true
	
	if db.data.settings.language in [db.LANGUAGE.CHINESE, db.LANGUAGE.CLASSICAL_CHINESE, db.LANGUAGE.JAPANESE]:
		font_width = quote_manager.font_size
	else:
		font_width = 21
	
	quote = Autowrap.smart_autowrap(quote, font_width + quote_manager.SPACING_GLYPH, quote_manager, 0, true)
	
	for character in quote:
		quote_manager.text += character
		if os.is_alpha(character):
			Audio.play_sound("txt_asgore")
		if character != "\n":
			await time.sleep(0.07)
		else:
			continue
	
	on_queue = false
