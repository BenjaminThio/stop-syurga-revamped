class_name CustomMenu extends Node

var options: Array
var height: int
var width: int
var paged: bool

func create_paged_menu(new_options: Array, option_quantity_in_a_page: int = 4) -> void:
	const MAX_HEIGHT: int = 2
	const MAX_WIDTH: int = 2
	
	paged = true
	
	if new_options.size() < 1:
		error("There must be at least one option on a menu.")
		return
	
	if option_quantity_in_a_page <= 0:
		error("Zero or negative value is unacceptable for the parameter(option_quantity_in_a_page).")
		return
	if option_quantity_in_a_page <= MAX_HEIGHT * MAX_WIDTH:
		options = group_array(new_options, option_quantity_in_a_page)
		for group_index in range(options.size()):
			options[group_index] = group_array(options[group_index], MAX_WIDTH)
		height = options[0].size()
		width = options[0][0].size()
	elif option_quantity_in_a_page > MAX_HEIGHT * MAX_WIDTH:
		error("The maximum option quantity in a group of a paged menu is {max_option_quantity_in_a_page}.".format({"max_option_quantity_in_a_page": MAX_HEIGHT * MAX_WIDTH}))
		return

func create_static_menu(new_options: Array[String], option_quantity_in_a_row: int) -> void:
	const MAX_HEIGHT: int = 3
	const MAX_WIDTH: int = 2
	
	paged = false
	
	if new_options.size() < 1:
		error("There must be at least one option on a menu.")
		return
	
	if option_quantity_in_a_row <= 0:
		error("Zero or negative width menu does not exist.")
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
		error("The maximum width of a static menu is {max_width}. Please create a paged menu instead.".format({"max_width": MAX_WIDTH}))
		return

func group_array(array: Array, element_quantity_in_a_group: int) -> Array[Array]:
	
	var grouped_array: Array[Array] = [[]]
	var element_counter: int = 0
	
	for array_element in array:
		if element_counter == element_quantity_in_a_group:
			grouped_array.append([])
			element_counter = 0
		grouped_array[grouped_array.size() - 1].append(array_element)
		element_counter += 1
	
	for _i in range(array.size() - (floor(array.size() / float(element_quantity_in_a_group)) * element_quantity_in_a_group)):
		grouped_array[grouped_array.size() - 1].append("")
	
	return grouped_array

func error(err: String) -> void:
	printerr(err)
	push_error(err)