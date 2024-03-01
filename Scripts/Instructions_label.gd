extends Node2D

@onready var confirm: Label = $Confirm
@onready var cancel: Label = $Cancel
@onready var fullscreen: Label = $Fullscreen
@onready var quit: Label = $Quit
@onready var hint: Label = $Hint

func _process(_delta):
	for label in get_children():
		instruction_label_resized(label)

func _on_confirm_resized():
	instruction_label_resized(confirm)

func _on_cancel_resized():
	instruction_label_resized(cancel)

func _on_fullscreen_resized():
	instruction_label_resized(fullscreen)

func _on_quit_resized():
	instruction_label_resized(quit)

func _on_hint_resized():
	instruction_label_resized(hint)

func instruction_label_resized(label: Label):
	var viewport_size_x: float = get_viewport().size.x
	
	#await get_tree().process_frame
	
	if label.global_position.x + label.size.x > viewport_size_x:
		global_position.x -= label.global_position.x + label.size.x - viewport_size_x
