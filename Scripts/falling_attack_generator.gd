extends VBoxContainer

var block: PackedScene = load("res://Instances/controlled_block.tscn")
var bomb: PackedScene = load("res://Instances/controlled_bomb.tscn")
var barrier: PackedScene = load("res://Instances/controlled_barrier.tscn")
var adjusted_location: bool = false

@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE
@export var transition_duration: float = 7.0
@export var rows_count: int = 5
@export var row_space: int = 150
@export var attacks_count_in_a_row: int = 4
@export var rewindable: bool = true
@export var attacks: Array[PackedScene] = [block, bomb]
@export var repeated_random_attack: bool = true

@onready var battlefield: NinePatchRect = get_tree().get_first_node_in_group("battlefield")

func _ready():
	for _row_index in range(rows_count):
		var h_box_container: HBoxContainer = HBoxContainer.new()
		
		h_box_container.alignment = BoxContainer.ALIGNMENT_CENTER
		set("theme_override_constants/separation", row_space)
		add_child(h_box_container)
		move_child(h_box_container, 0)
		
		if repeated_random_attack:
			for _attack_index in range(attacks_count_in_a_row):
				var random_attack: PackedScene = random.choice(attacks)
				
				h_box_container.add_child(random_attack.instantiate())
		else:
			for random_attack in random.sample(attacks, attacks_count_in_a_row):
				
				h_box_container.add_child(random_attack.instantiate())

func _on_resized():
	if not adjusted_location:
		adjusted_location = true
		global_position.y = -size.y
		if rewindable and battlefield != null:
			var recorder_sign: AnimatedSprite2D = battlefield.get_node("RecorderSign")
			
			battlefield.sign_activated = true
			recorder_sign.frame = 0
		create_tween().set_trans(transition_type).tween_property(self, "global_position:y", get_viewport_rect().size.y / [1, 1.5][int(rewindable)], transition_duration).finished.connect(
			func() -> void:
				if not rewindable:
					queue_free()
				if battlefield != null:
					var recorder_sign: AnimatedSprite2D = battlefield.get_node("RecorderSign")
					
					recorder_sign.frame = 1
				create_tween().set_trans(transition_type).tween_property(self, "global_position:y", -size.y, transition_duration).finished.connect(
					func() -> void:
						if battlefield != null:
							battlefield.sign_activated = false
							queue_free()
				)
		)
