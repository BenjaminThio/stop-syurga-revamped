extends Node

enum LANGUAGE {
	ENGLISH,
	CHINESE,
	CLASSICAL_CHINESE,
	MALAY,
	JAPANESE
}
var save_path: String = "user://save.save"
var default_data: Dictionary = {
	player = {
		name = null,
		id = null,
		uid = null,
		exp = 10000,
		gold = 0,
		playtime = 0,
		location_index = 0
	},
	settings = {
		language = LANGUAGE.ENGLISH
	}
}
var data: Dictionary = default_data.duplicate(true)
var exp_to_level: Array[int] = [
	0,
	10,
	30,
	70,
	120,
	200,
	300,
	500,
	800,
	1200,
	1700,
	2500,
	3500,
	5000,
	7000,
	10000,
	15000,
	25000,
	50000,
	99999
]

func _ready():
	load_data()
	level_define_all()

func load_data() -> Dictionary:
	if FileAccess.file_exists(save_path):
		var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
		data = file.get_var()
	else:
		save_data()
	return data

func save_data() -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	file.store_var(data)

func get_player_level() -> int:
	for level_index in range(exp_to_level.size()):
		if data.player.exp < exp_to_level[level_index]:
			return level_index
	return exp_to_level.size()

func level_define_all() -> void:
	level_define_max_hit_points()
	level_define_attack()
	level_define_defense()

func level_define_max_hit_points() -> void:
	if get_player_level() < PlayerData.max_level:
		PlayerData.max_health = PlayerData.base_hit_points + (PlayerData.hit_points_bonus_per_level * get_player_level())
	elif get_player_level() >= PlayerData.max_level:
		PlayerData.max_health = PlayerData.max_hit_points_bonus

func level_define_attack() -> void:
		PlayerData.attack = -2 + (PlayerData.attack_bonus_per_level * get_player_level())

func level_define_defense() -> void:
	PlayerData.defense = floor((get_player_level() - 1) / 4.0)
