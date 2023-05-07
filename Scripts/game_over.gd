extends Control

var quotes: Array[String] = ["The future of\nmonsters depends\non you!", "Don't lose hope!", "You cannot give\nup just yet..."]
var on_queue: bool = false
var phases: int = 0

@onready var main: Node2D = get_tree().get_root().get_node("Main")
@onready var game_over_label: Label = $Title
@onready var quote_label: Label = $Quote

func _ready() -> void:
	game_over_label.self_modulate.a = 0
	quote_label.text = ""
	main.background_music_player.volume_db = 0.0
	
	main.play_audio("res://Musics/Game Over.mp3")
	
	on_queue = true
	create_tween().tween_property(game_over_label, "self_modulate:a", 1, 1.5)
	await time.sleep(1.5)
	on_queue = false
	
	var random_quote: String = random.choice(quotes)
	
	await asgore_say(random_quote)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("accept") and not on_queue:
		phases += 1
		quote_label.text = ""
		if phases == 1:
			await asgore_say("{name}!\nStay determined.".format({"name": db.human_name}))
		elif phases == 2:
			on_queue = true
			await time.sleep(3)
			create_tween().tween_property(game_over_label, "self_modulate:a", 0, 1.5)
			create_tween().tween_property(main.background_music_player, "volume_db", -10, 1.5)
			await time.sleep(1.5)
			on_queue = false
			
			get_tree().quit()

func asgore_say(quote: String) -> void:
	on_queue = true
	
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	
	for character in quote:
		quote_label.text += character
		if regex.search(character):
			main.play_sound_effect("Asgore Voice")
		await time.sleep(0.07)
	
	await time.sleep(5)
	
	on_queue = false
