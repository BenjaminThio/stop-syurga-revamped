extends Node2D

func locate_red_spear():
	if get_child_count() > 0 and get_child(0).is_in_group("spear"):
		get_child(0).get_node("AnimatedSprite").frame = 1

func destroy_spear_and_locate_red_spear(spear: Node2D):
	#remove_child(spear)
	spear.queue_free()
	
	await get_tree().process_frame
	
	locate_red_spear()
