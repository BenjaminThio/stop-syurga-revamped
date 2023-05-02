extends ProgressBar

func _ready() -> void:
	set_max_health(20)
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
		var error: String = "The negative damage value is not acceptable, please use \"heal()\" function instead."
		printerr(error)
		push_error(error)
		return
	
	if db.health - damage_value >= 0:
		db.health -= damage_value
	else:
		db.health = 0
	update_health_bar()

func heal(heal_value: float) -> void:
	if heal_value < 0:
		var error: String = "The negative heal value is not acceptable, please use \"deal_damage()\" function instead."
		printerr(error)
		push_error(error)
		return
	
	if db.health + heal_value <= max_value:
		db.health += heal_value
	else:
		db.health = max_value
	update_health_bar()

func update_health_bar() -> void:
	value = db.health
	
	var health_label: Label = get_parent().get_child(get_parent().get_child_count() - 1)
	health_label.text = "{health} / {max_health}".format({"health": db.health, "max_health": max_value})

func set_max_health(max_health_value: float) -> void:
	db.max_health = max_health_value
	max_value = db.max_health
