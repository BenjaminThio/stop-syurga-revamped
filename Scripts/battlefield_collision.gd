@tool
extends CollisionPolygon2D

@onready var battlefield: NinePatchRect = get_parent().get_parent() #get_tree().get_first_node_in_group("battlefield")
@onready var battlefield_original_size: Vector2 = battlefield.size

func _on_battlefield_resized() -> void:
	if battlefield_original_size > battlefield.size:
		shrink()
	elif battlefield_original_size < battlefield.size:
		expand()
	battlefield_original_size = battlefield.size

func shrink() -> void:
	move_inner_vertices()
	move_outer_vertices()

func expand() -> void:
	move_outer_vertices()
	move_inner_vertices()

func move_inner_vertices() -> void:
	#inner bottom right
	polygon[5] = Vector2(battlefield.size.x, battlefield.size.y - 1.346)
	
	#inner bottom left
	polygon[6] = Vector2(16, battlefield.size.y - 1.346)
	
	for vertex_index in [4, 8]:
		#inner top right
		polygon[vertex_index] = Vector2(battlefield.size.x, 14.654)

func move_outer_vertices() -> void:
	#outer bottom left
	polygon[1] = Vector2(8, battlefield.size.y + 6.654)
	
	#outer bottom right
	polygon[2] = Vector2(battlefield.size.x + 8, battlefield.size.y + 6.654)
	
	for vertex_index in [3, 9]:
		#outer top right
		polygon[vertex_index] = Vector2(battlefield.size.x + 8, 6.654)
