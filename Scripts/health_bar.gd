extends ProgressBar

@onready var stats: HBoxContainer = get_parent()

func _ready() -> void:
	update_health_bar()

func _process(_delta) -> void:
	pass
	"""
	if Input.is_action_just_pressed("test1"):
		deal_damage(1)
	elif Input.is_action_just_pressed("test2"):
		heal(1)
	"""

func deal_damage(damage_value: float) -> void:
	if damage_value < 0:
		Debug.log_error("The negative damage value is not acceptable, please use \"heal()\" function instead.", true)
		return
	
	if PlayerData.health - damage_value >= 0:
		PlayerData.health -= damage_value
	else:
		PlayerData.health = 0
	update_health_bar()
	
	if PlayerData.health == 0:
		owner.game_over()

func heal(heal_value: float) -> void:
	if heal_value < 0:
		Debug.log_error("The negative heal value is not acceptable, please use \"deal_damage()\" function instead.", true)
		return
	
	if PlayerData.health + heal_value <= PlayerData.max_health:
		PlayerData.health += heal_value
	else:
		PlayerData.health = PlayerData.max_health
	update_health_bar()

func update_health_bar() -> void:
	max_value = PlayerData.max_health
	value = PlayerData.health
	
	stats.update_health_label()
