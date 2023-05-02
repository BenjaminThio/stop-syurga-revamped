class_name Mercy extends Node

const OPTIONS: Array[String] = ["spare", "flee"]

func select_option(option: String) -> void:
	if option == "spare":
		print("Testing123!")
	elif option == "flee":
		print("Hello World!")
