extends Node2D

func _ready():
	$Label.text = Autowrap.smart_autowrap("我我我我我我我我我 我", 30, $ColorRect)
