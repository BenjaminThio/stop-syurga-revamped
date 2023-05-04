class_name random extends Node

static func choice(seq: Array):
	return seq[randi() % seq.size()]

static func choices(seq: Array, k: int = 1) -> Array:
	var result: Array = []
	
	for _i in range(k):
		result.append(choice(seq))
	
	return result

static func sample(seq: Array, k: int = 1):
	var result: Array = []
	
	if k > seq.size():
		var error: String = "ValueError: Sample larger than population or is negative"
		
		printerr(error)
		push_error(error)
		return
	
	for _i in range(k):
		var random_index = randi() % seq.size()
		
		result.append(seq[random_index])
		seq.pop_at(random_index)
	
	return result
