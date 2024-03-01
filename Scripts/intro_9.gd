extends Node2D

@onready var memory: Sprite2D = $Memory
@onready var yi_fan_cloud: Sprite2D = $YiFanCloud

func _ready():
	var tween: Tween
	
	#await time.sleep(1.0)
	
	tween = create_tween()
	
	memory.position.y = 14.2
	tween.set_parallel().tween_property(self, "modulate:a", 1.0, 0.5)
	tween.set_parallel().tween_property(memory, "position:y", 285.8, 10.0)
	
	await time.sleep(10.5)
	
	tween = create_tween()
	
	tween.tween_property(yi_fan_cloud, "self_modulate:a", 0.2, 2.0)
