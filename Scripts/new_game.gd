extends Node

enum SCENE {
	INSTRUCTION,
	NAME
}
var readied: bool = false
var actived_scene: SCENE = SCENE.INSTRUCTION
var name_label_text: String = ""
var keyboard_coord: Vector2 = Vector2.ZERO
var instruction_scene: PackedScene = preload("res://Instances/instruction.tscn")
var name_scene: PackedScene = preload("res://Instances/name.tscn")
@onready var background_music_player: AudioStreamPlayer = $BackgroundMusic

func _ready():
	if Global.reset:
		actived_scene = SCENE.NAME
	activate_scene(actived_scene)
	readied = true

func activate_scene(scene: SCENE):
	if scene < SCENE.size() and not readied or scene != actived_scene:
		actived_scene = scene
		if readied:
			for child in get_children():
				if child != background_music_player:
					child.queue_free()
		if actived_scene == SCENE.INSTRUCTION:
			add_child(instruction_scene.instantiate())
		elif actived_scene == SCENE.NAME:
			add_child(name_scene.instantiate())
