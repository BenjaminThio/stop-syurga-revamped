extends Node

const PROTECTED_VARIABLE: String = "You can't access protected variable!"

func log_error(error, required_print_stack: bool = false):
	printerr(error)
	push_error(error)
	if required_print_stack:
		log_stack()

func log_warning(warning, required_print_stack: bool = false):
	print("⬤ Warning: {warning}".format({"warning": warning}))
	push_warning(warning)
	if required_print_stack:
		log_stack()

func log_stack() -> void:
	var debug_stack: String = ""
	var raw_stacks: Array[Dictionary] = get_stack()
	var stacks: Array[Dictionary] = []
	
	for stack_index in range(raw_stacks.size()):
		if raw_stacks[stack_index].source != get_script().get_path():
			stacks.append(raw_stacks[stack_index])
	
	for stack_index in range(stacks.size()):
		var stack: Dictionary = stacks[stack_index]
		var connector: String
		
		if stack_index < stacks.size() - 1:
			debug_stack += "┠╴"
			connector = "┃  "
		else:
			debug_stack += "┖╴"
			connector = "\t"
		debug_stack += "At: {source}\n{connector}┠╴line: {line}\n{connector}┖╴function: \'{function}\'\n".format({"source": stack.source, "line": stack.line, "function": stack.function, "connector": connector})
	print(debug_stack)