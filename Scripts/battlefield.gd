@tool
extends NinePatchRect

const GRID_STEP: int = 8
const BLINK_DURATION: float = 0.3
var sign_activated: bool = false
var toggling_sign_visibility: bool = false
@export var transition_time: float = 0.5
@onready var webs: Array[Node] = $Webs.get_children()
@onready var recorder_sign: AnimatedSprite2D = $RecorderSign

func _ready():
	if not Engine.is_editor_hint():
		set_property(Vector2(768, 192), Vector2(192, 336))

func _process(_delta):
	if sign_activated and not toggling_sign_visibility:
		toggling_sign_visibility = true
		recorder_sign.visible = not recorder_sign.visible
		await time.sleep(BLINK_DURATION, func() -> void: if not sign_activated: recorder_sign.visible = false)
		toggling_sign_visibility = false

func set_property(new_size: Vector2, new_position: Vector2, require_tween: bool = false) -> void:
	if require_tween:
		#set_webs_length(new_size.x, true)
		create_tween().tween_property(self, "size", new_size, transition_time)
		await create_tween().tween_property(self, "position", new_position, transition_time).finished
	else:
		#set_webs_length(new_size.x)
		size = new_size
		position = new_position

func set_webs_length(new_length: float, require_tween: bool = false) -> void:
	for web in webs:
		if require_tween:
			create_tween().tween_property(web, "size:x", new_length - (GRID_STEP * 2), transition_time)
		else:
			web.size.x = new_length - (GRID_STEP * 2)

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
	set_webs_length(size.x)
	recorder_sign.position = size
