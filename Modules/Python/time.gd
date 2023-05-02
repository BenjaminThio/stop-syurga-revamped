extends Node

func sleep(sec: float) -> void:
	await get_tree().create_timer(sec).timeout
