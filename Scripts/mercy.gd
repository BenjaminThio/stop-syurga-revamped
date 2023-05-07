class_name Mercy extends Node

enum OPTION {
	SPARE,
	FLEE
}

func select_option(option: int) -> void:
	if option == OPTION.SPARE:
		print("Testing123!")
	elif option == OPTION.FLEE:
		print("Hello World!")
