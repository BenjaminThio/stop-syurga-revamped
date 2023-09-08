extends Node

class_name ModifiedNode

static func clear_children(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
