@tool
extends NinePatchRect

var transition_time: float = 0.5

func _ready() -> void:
	#set_property(Vector2(272, 192), Vector2(440, 336), true)
	set_property(Vector2(768, 192), Vector2(192, 336))

func set_property(new_size: Vector2, new_position: Vector2, require_tween: bool = false) -> void:
	if require_tween:
		create_tween().tween_property(self, "size", new_size, transition_time)
		create_tween().tween_property(self, "position", new_position, transition_time)
	else:
		size = new_size
		position = new_position

func expand(size_x: float = 576, position_x: float = 288, require_tween: bool = true) -> void:
	if require_tween:
		create_tween().tween_property(self, "size:x", size.x + size_x, transition_time)
		create_tween().tween_property(self, "position:x", position.x - position_x, transition_time)
	else:
		size.x += size_x
		position.x -= position_x

func shrink(size_x: float = 576, position_x: float = 288, require_tween: bool = true) -> void:
	if require_tween:
		create_tween().tween_property(self, "size:x", size.x - size_x, transition_time)
		create_tween().tween_property(self, "position:x", position.x + position_x, transition_time)
	else:
		size.x -= size_x
		position.x += position_x

func _on_resized() -> void:
	pivot_offset = Vector2(size.x / 2, size.y / 2)
