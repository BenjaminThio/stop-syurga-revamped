class_name CustomMenu extends Node

var options: Array:
	get:
		return options
	set(value):
		if get_stack()[1].source == get_script().get_path():
			options = value
		else:
			Debug.log_warning(Debug.PROTECTED_VARIABLE_NOT_ACCESSIBLE, true)
var width: int:
	get:
		return width
	set(value):
		if get_stack()[1].source == get_script().get_path():
			width = value
		else:
			Debug.log_warning(Debug.PROTECTED_VARIABLE_NOT_ACCESSIBLE, true)
var height: int:
	get:
		return height
	set(value):
		if get_stack()[1].source == get_script().get_path():
			height = value
		else:
			Debug.log_warning(Debug.PROTECTED_VARIABLE_NOT_ACCESSIBLE, true)
var paged: bool:
	get:
		return paged
	set(value):
		if get_stack()[1].source == get_script().get_path():
			paged = value
		else:
			Debug.log_warning(Debug.PROTECTED_VARIABLE_NOT_ACCESSIBLE, true)

func create_paged_menu(new_options: Array, option_quantity_in_a_page: int = 4) -> void:
	const MAX_HEIGHT: int = 2
	const MAX_WIDTH: int = 2
	
	paged = true
	
	if new_options.size() < 1:
		Debug.log_error("There must be at least one option on a menu.")
		return
	
	if option_quantity_in_a_page <= 0:
		Debug.log_error("Zero or negative value is unacceptable for the parameter(option_quantity_in_a_page).")
		return
	if option_quantity_in_a_page <= MAX_HEIGHT * MAX_WIDTH:
		options = group_array(new_options, option_quantity_in_a_page)
		for group_index in range(options.size()):
			options[group_index] = group_array(options[group_index], MAX_WIDTH)
		height = options[0].size()
		width = options[0][0].size()
		
		while options[options.size() - 1].size() < height:
			options[options.size() - 1].append([])
			for _i in range(MAX_WIDTH):
				options[options.size() - 1][options[options.size() - 1].size() - 1].append(null)
		
	elif option_quantity_in_a_page > MAX_HEIGHT * MAX_WIDTH:
		Debug.log_error("The maximum option quantity in a group of a paged menu is {max_option_quantity_in_a_page}.".format({"max_option_quantity_in_a_page": MAX_HEIGHT * MAX_WIDTH}))
		return

func create_static_menu(new_options: Array, option_quantity_in_a_row: int) -> void:
	const MAX_HEIGHT: int = 3
	const MAX_WIDTH: int = 2
	
	paged = false
	
	if new_options.size() < 1:
		Debug.log_error("There must be at least one option on a menu.")
		return
	
	if option_quantity_in_a_row <= 0:
		Debug.log_error("Zero or negative width menu does not exist.")
		return
	elif option_quantity_in_a_row <= MAX_WIDTH:
		options = group_array(new_options, option_quantity_in_a_row)
		width = option_quantity_in_a_row
		height = options.size()
		if height > MAX_HEIGHT:
			for _i in range(height - MAX_HEIGHT):
				options.pop_back()
			push_warning("Removed {removed_row_count} unshown/useless rows.".format({"removed_row_count": height - MAX_HEIGHT}))
			height = MAX_HEIGHT
	elif option_quantity_in_a_row > MAX_WIDTH:
		Debug.log_error("The maximum width of a static menu is {max_width}. Please create a paged menu instead.".format({"max_width": MAX_WIDTH}))
		return

func group_array(array: Array, element_quantity_in_a_group: int, null_value = null) -> Array[Array]:
	
	var grouped_array: Array[Array] = [[]]
	var element_counter: int = 0
	
	for array_element in array:
		if element_counter == element_quantity_in_a_group:
			grouped_array.append([])
			element_counter = 0
		grouped_array[grouped_array.size() - 1].append(array_element)
		element_counter += 1
	
	for _i in range(array.size() - (floor(array.size() / float(element_quantity_in_a_group)) * element_quantity_in_a_group)):
		grouped_array[grouped_array.size() - 1].append(null_value)
	
	return grouped_array
