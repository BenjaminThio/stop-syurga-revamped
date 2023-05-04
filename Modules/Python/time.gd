extends Node

func create_timer(sec: float) -> SceneTreeTimer:
	return get_tree().create_timer(sec)
	
func sleep(sec: float, timeout_function: Callable = Callable()):
	var timer: SceneTreeTimer = create_timer(sec)
	
	if not timeout_function.is_null():
		timer.timeout.connect(timeout_function)
	await timer.timeout
