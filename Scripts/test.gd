extends Node2D

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		for _i in range(5):
			var shard: AnimatedSprite2D = load("res://Instances/shard.tscn").instantiate()
			
			add_child(shard)
