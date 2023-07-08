extends Node2D

func locate_red_spear():
	if get_child_count() > 0:
		get_child(0).get_node("AnimatedSprite").frame = 1

func destroy_spear_and_locate_red_spear(spear: Area2D):
	#remove_child(spear)
	spear.queue_free()
	await time.sleep(0.001, locate_red_spear)
