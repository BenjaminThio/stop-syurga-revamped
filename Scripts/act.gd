class_name Act extends Node

const OPTIONS: Array[String] = ["check", "greet", "explain", "tease", "hug", "change music"]

func select_option(option: String) -> void:
	if option == "change music":
		var file_dialog: FileDialog = FileDialog.new()
		
		owner.add_child(file_dialog)
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.size = Vector2(450, 500)
		file_dialog.set_filters(["*ogg", "*wav", "*mp3"])
		file_dialog.file_selected.connect(owner.play_audio)
		file_dialog.popup_centered()
