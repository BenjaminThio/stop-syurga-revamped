extends TextureRect

@export var min_value: float = 0
@export var max_value: float = 100
@export var bus_channel: Global.BUS_CHANNEL = Global.BUS_CHANNEL.MASTER
@export var gradient: Gradient
@export var grabber_offset: float = 2
@export var volume_display_label: Label = null

var is_holding_grabber: bool = false
var interactable: bool = false

@onready var grabber = $Grabber

func _ready() -> void:
	update_grabber()
	update_slider()
	display_volume()

func _input(event: InputEvent):
	if not interactable or not (event is InputEventMouseMotion) and not (event is InputEventMouseButton):
		return
	
	var cursor_position: Vector2 = event.position
	
	if event is InputEventMouseMotion and is_holding_grabber or event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and cursor_position.x >= global_position.x and cursor_position.x <= global_position.x + size.x and cursor_position.y >= global_position.y and cursor_position.y <= global_position.y + size.y:
		if event is InputEventMouseMotion and is_holding_grabber:
			if cursor_position.x >= global_position.x - grabber_offset and cursor_position.x <= global_position.x + size.x - grabber_offset:
				grabber.global_position.x = cursor_position.x
			elif cursor_position.x < global_position.x - grabber_offset:
				grabber.global_position.x = global_position.x - grabber_offset
			elif cursor_position.x > global_position.x + size.x - cursor_position.x:
				grabber.global_position.x = global_position.x + size.x - grabber_offset
			
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and cursor_position.x >= global_position.x and cursor_position.x <= global_position.x + size.x and cursor_position.y >= global_position.y and cursor_position.y <= global_position.y + size.y:
			grabber.global_position.x = cursor_position.x - grabber_offset
		
		Global.update_audio_server()
		update_slider()
		display_volume()
		save_data()

func display_volume() -> void:
	if volume_display_label != null:
		volume_display_label.text = str(snapped(Global.get_value_in_range(min_value, max_value, get_slider_value()), 1)) + "%"

func update_grabber() -> void:
	var slider_initial_position: float = global_position.x - grabber_offset
	var slider_final_position: float = global_position.x + size.x - grabber_offset
	var volume_fraction: float
	
	if bus_channel == Global.BUS_CHANNEL.MASTER:
		volume_fraction = db.data.settings.master_volume
	elif bus_channel == Global.BUS_CHANNEL.BGM:
		volume_fraction = db.data.settings.bgm_volume
	elif bus_channel == Global.BUS_CHANNEL.SFX:
		volume_fraction = db.data.settings.sfx_volume
	
	grabber.global_position.x = Global.get_value_in_range(slider_initial_position, slider_final_position, volume_fraction)

func update_slider() -> void:
	self_modulate = gradient.sample(get_slider_value())

func get_slider_value() -> float:
	#printt((grabber.global_position.x - global_position.x + grabber_offset) / size.x, bus_channel)
	return (grabber.global_position.x - global_position.x + grabber_offset) / size.x

func save_data() -> void:
	if bus_channel == Global.BUS_CHANNEL.MASTER:
		db.data.settings.master_volume = get_slider_value()
	elif bus_channel == Global.BUS_CHANNEL.BGM:
		db.data.settings.bgm_volume = get_slider_value()
	elif bus_channel == Global.BUS_CHANNEL.SFX:
		db.data.settings.sfx_volume = get_slider_value()
	
	db.save_data()

func _on_grabber_down() -> void:
	is_holding_grabber = true

func _on_grabber_up() -> void:
	is_holding_grabber = false
