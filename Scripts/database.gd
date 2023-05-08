extends Node

const min_name_length: int = 3
const max_name_length: int = 8
const max_level: int = 20
const base_hit_points: int = 16
const hit_points_bonus_per_level: int = 4
const max_hit_points_bonus: int = 99
const attack_bonus_per_level: int = 2

var player_name: String = "Benjamin":
	get:
		return player_name
	set(value):
		set_player_name(value)

var level: int:
	get:
		return level
	set(value):
		if value > max_level:
			value = max_level
			
		if get_stack()[1].source == get_script().get_path():
			var level_define_max_hit_points: Callable = Callable(
				func() -> void:
					if level < max_level:
						max_health = base_hit_points + (hit_points_bonus_per_level * level) # (hit_points_bonus_per_level * (level - 1)) + hit_points_bonus_per_level
					elif level >= max_level:
						max_health = max_hit_points_bonus
			)
			
			var level_define_attack: Callable = Callable(
				func() -> void:
					attack = -2 + (attack_bonus_per_level * level) # attack_bonus_per_level * (level - 1)
			)
			
			var level_define_defense: Callable = Callable(
				func() -> void:
					defense = floor((level - 1) / 4.0)
			)
			
			level = value
			level_define_max_hit_points.call()
			level_define_attack.call()
			level_define_defense.call()
		else:
			pass
			#Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var max_health: float:
	get:
		return max_health
	set(value):
		if get_stack()[1].source == get_script().get_path():
			max_health = value
			get_tree().get_first_node_in_group("health_bar").set_max(max_health)
		else:
			Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var health: float = 5.0
var items: Array[Item] = [
	Item.new("Bing Chilling", 5),
	Item.new("Zen An", 10),
	Item.new("Zen Thye", 15),
	Item.new("Choon Hong", 20),
	Item.new("Benjamin", 25),
	Item.new("Yao Zong", 30),
	Item.new("Bing Chilling", 35),
	Item.new("Bing Chilling", 40)
]

var defense: float:
	get:
		return defense
	set(value):
		if get_stack()[1].source == get_script().get_path():
			defense = value
		else:
			Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var attack: float:
	get:
		return attack
	set(value):
		if get_stack()[1].source == get_script().get_path():
			attack = value
		else:
			Debug.log_warning(Debug.PRIVATE_VARIABLE_NOT_ACCESSIBLE, true)
var weapon: String
var armor: String

func _ready() -> void:
	level = 20

func level_up() -> void:
	if level + 1 <= max_level:
		level += 1

func set_player_name(value: String):
	value = value.strip_edges()
		
	if value.length() < min_name_length and value.length() > max_name_length:
		if value.length() == 0:
			value = str(null)
		elif value.length() > 0 and value.length() < min_name_length:
			while value.length() < min_name_length:
				value += str(randi_range(0, 9))
		elif value.length() > max_name_length:
			value = value.left(max_name_length)
		Debug.log_warning(Debug.INVALID_PLAYER_NAME, true)
	
	player_name = value
