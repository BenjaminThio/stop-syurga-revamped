extends Node

const PRIVATE_VARIABLE_NOT_ACCESSIBLE: String = "You can't access to this private variable out of the current script!"
const PROTECTED_VARIABLE_NOT_ACCESSIBLE: String = "You can't access to this protected variable."
const INVALID_PLAYER_NAME: String = "This player name is invalid!"
const ARGUMENT_TYPE_UNACCEPTABLE: String = "Cannot pass value of type \"{unacceptable_type}\" as \"{acceptable_types}\""
#const NEGATIVE_ARGUMENT_NOT_ACCEPTABLE: String = "This argument's value shouldn't be negative."

func type_of(value) -> int:
	match typeof(value):
		TYPE_AABB:
			#A 3D axis-aligned bounding box.
			print("AABB (A 3D Axis-aligned bounding box)")
		TYPE_ARRAY:
			print("Array")
		TYPE_BASIS:
			#A 3×3 matrix for representing 3D rotation and scale.
			print("Basis")
		TYPE_BOOL:
			print("bool (Boolean)")
		TYPE_CALLABLE:
			print("Callable")
		TYPE_COLOR:
			print("Color")
		TYPE_DICTIONARY:
			print("Dictionary")
		TYPE_FLOAT:
			print("float")
		TYPE_INT:
			print("int (Integer)")
		TYPE_MAX:
			print("Max")
		TYPE_NIL:
			print("Nil (Null)")
		TYPE_NODE_PATH:
			print("NodePath")
		TYPE_OBJECT:
			print("Object - " + value.get_class())
		TYPE_PACKED_BYTE_ARRAY:
			print("PackedByteArray")
		TYPE_PACKED_COLOR_ARRAY:
			print("PackedColorArray")
		TYPE_PACKED_FLOAT32_ARRAY:
			print("PackedFloat32Array")
		TYPE_PACKED_FLOAT64_ARRAY:
			print("PackedFloat64Array")
		TYPE_PACKED_INT32_ARRAY:
			print("PackedInt32Array")
		TYPE_PACKED_INT64_ARRAY:
			print("PackedInt64Array")
		TYPE_PACKED_STRING_ARRAY:
			print("PackedStringArray")
		TYPE_PACKED_VECTOR2_ARRAY:
			print("PackedVector2Array")
		TYPE_PACKED_VECTOR3_ARRAY:
			print("PackedVector3Array")
		TYPE_PLANE:
			print("Plane")
		TYPE_PROJECTION:
			print("Projection")
		TYPE_QUATERNION:
			print("Quaternion")
		TYPE_RECT2:
			#A 2D axis-aligned bounding box using floating-point coordinates.
			print("Rect2 (A 2D axis-aligned bounding box using floating-point coordinates)")
		TYPE_RECT2I:
			#A 2D axis-aligned bounding box using integer coordinates.
			print("Rect2i (A 2D axis-aligned bounding box using integer coordinates)")
		TYPE_RID:
			print("RID (Resource ID)")
		TYPE_SIGNAL:
			print("Signal")
		TYPE_STRING:
			print("String")
		TYPE_STRING_NAME:
			print("StringName")
		TYPE_TRANSFORM2D:
			print("Transform2D")
		TYPE_TRANSFORM3D:
			print("Transform3D")
		TYPE_VECTOR2:
			print("Vector2")
		TYPE_VECTOR2I:
			print("Vector2i")
		TYPE_VECTOR3:
			print("Vector3")
		TYPE_VECTOR3I:
			print("Vector3i")
		TYPE_VECTOR4:
			print("Vector4")
		TYPE_VECTOR4I:
			print("Vector4i")
		_:
			print("Unknown")
	return typeof(value)

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
