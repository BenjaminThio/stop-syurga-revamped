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
	
	if db.health - damage_value >= 0:
		db.health -= damage_value
	else:
		db.health = 0
	update_health_bar()
	
	if db.health == 0:
		owner.game_over()

func heal(heal_value: float) -> void:
	if heal_value < 0:
		Debug.log_error("The negative heal value is not acceptable, please use \"deal_damage()\" function instead.", true)
		return
	
	if db.health + heal_value <= db.max_health:
		db.health += heal_value
	else:
		db.health = db.max_health
	update_health_bar()

func update_health_bar() -> void:
	value = db.health
	
	stats.update_health_label()
