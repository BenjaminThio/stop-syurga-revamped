extends Camera2D

@onready var origin = position

func camera_shake(times: int = 5, default_delay_time: float = 0.01, fixed_delay_time: bool = false) -> void:
	var offset_sign: bool = false
	var delay_time: float = default_delay_time
	var shake_range: Array = range(times, 0, -1)
	
	for shake_index in shake_range:
		position = Vector2(origin.x + generate_random_shake_offset(shake_index, offset_sign), origin.y + generate_random_shake_offset(shake_index, offset_sign))
		offset_sign = not offset_sign
		if not fixed_delay_time:
			delay_time = default_delay_time * shake_range[shake_index - 1]
		await time.sleep(delay_time)
	position = origin

func generate_random_shake_offset(shake_index: int, offset_sign: bool) -> int:
	var offset_values = [-1, 1]
	
	return offset_values[randi() % offset_values.size()] * shake_index * ((int(offset_sign) * 2) - 1)
