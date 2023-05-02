class_name os extends Node

static func listdir(path: String) -> Array[String]:
	var files: Array[String] = []
	var directory: DirAccess = DirAccess.open(path)
	
	directory.list_dir_begin()
	
	while true:
		var file: String = directory.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	directory.list_dir_end()
	
	return files
