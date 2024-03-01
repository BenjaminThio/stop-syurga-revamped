extends Node2D

@onready var galaxy: Sprite2D = $Galaxy
@onready var old_galaxy: Sprite2D = $OldGalaxy
@onready var question_mark: Sprite2D = $QuestionMark

func _ready():
	var tween: Tween = create_tween()
	
	tween.set_parallel().tween_property(self, "modulate:a", 1.0, 0.5).finished.connect(galaxy.show)
	tween.set_parallel().tween_property(galaxy, "scale", Vector2(3, 3), 9.0) #Vector2(3, 3), 5.0
	tween.set_parallel().tween_property(old_galaxy, "scale", Vector2(3, 3), 9.0) #Vector2(3, 3), 5.0
	
	await time.sleep(1.0)
	
	tween = create_tween()
	
	tween.set_parallel().tween_property(old_galaxy, "self_modulate:a", 0, 3.0)
	tween.set_parallel().tween_property(question_mark, "self_modulate:a", 1.0, 3.0)
	tween.set_parallel().tween_property(question_mark, "scale", Vector2(3, 3), 4.0)
