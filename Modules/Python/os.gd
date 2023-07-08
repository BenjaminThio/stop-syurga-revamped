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

static func is_alpha(string: String):
	var regex: RegEx = RegEx.new()
	
	regex.compile("[\\p{P}\\p{S}\\p{Sm}\\p{Sc}\\p{Sk}\\p{So}\\s]")
	if not regex.search(string):
		return true
	else:
		return false

"""
static func is_alpha(string: String):
	regex.compile("[a-zA-Z]+")
	if regex.search(string):
		#return true
	else:
		return false
"""
