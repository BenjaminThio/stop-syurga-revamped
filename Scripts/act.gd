class_name Act extends Node

enum OPTION {
	CHECK,
	GREET,
	EXPLAIN,
	TEASE,
	HUG,
	CHANGE_MUSIC
}

func select_option(option: int) -> void:
	if option == OPTION.CHANGE_MUSIC:
		var file_dialog: FileDialog = FileDialog.new()
		
		owner.set_pause(true)
		owner.add_child(file_dialog)
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.size = Vector2(450, 500)
		file_dialog.set_filters(["*ogg", "*wav", "*mp3"])
		file_dialog.file_selected.connect(on_file_selected)
		file_dialog.popup_centered()

func on_file_selected(path: String):
	var menu: VBoxContainer = get_tree().get_first_node_in_group("menu")
	
	owner.play_audio(path)
	menu.had_made_a_choice()
	owner.set_pause(false)
