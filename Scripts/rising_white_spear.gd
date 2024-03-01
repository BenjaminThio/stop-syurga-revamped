extends Area2D

@export var load_duration: float = 0.4
@export var spear_appear_delay_duration: float = 0.1
@export var move_delay_duration: float = 0.5
@export var move_distance: float = 67
@export var move_duration: float = 0.2
@export var disappear_duration: float = 0.5
@export var damage_multiplier: int = 2

@onready var villain: Area2D = get_tree().get_first_node_in_group("villain")

func _ready():
	modulate.a = 0
	
	create_tween().tween_property(self, "modulate:a", 1, load_duration).set_delay(spear_appear_delay_duration)
	create_tween().tween_property(self, "position:y", 0, load_duration).finished.connect(
		func() -> void:
			Audio.play_sound("spearappear")
			
			await time.sleep(move_delay_duration)
			
			create_tween().tween_property(self, "position:y", position.y - move_distance, move_duration).finished.connect(
				func() -> void:
					Audio.play_sound("spearrise")
					create_tween().tween_property(self, "modulate:a", 0, disappear_duration)
					
					await time.sleep(disappear_duration * 2 / 5)
					#await time.sleep(disappear_duration / 2)
					
					monitoring = false
					monitorable = false
					
					await time.sleep(disappear_duration * 3 / 5)
					#await time.sleep(disappear_duration / 2)
					
					queue_free()
			)
	)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.deal_damage(villain.attack * damage_multiplier)
