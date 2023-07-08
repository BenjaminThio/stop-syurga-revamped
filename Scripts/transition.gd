extends Node2D

func fade_in(canvas: Control, callable: Callable, transition_time: float = 0.5, color: Color = Color.BLACK):
	var color_rect: ColorRect = ColorRect.new()
	
	canvas.top_level = true
	color_rect.size = get_viewport_rect().size
	color_rect.self_modulate = color
	color_rect.self_modulate.a = 0
	canvas.add_child(color_rect)
	create_tween().tween_property(color_rect, "self_modulate:a", 1, transition_time)
	
	await time.sleep(transition_time, callable)

func curtain_open(canvas: Control, callable: Callable, transition_time: float = 1.5, color: Color = Color.BLACK):
	var viewport_size: Vector2 = get_viewport_rect().size
	var half_viewport_width: float = viewport_size.x / 2
	var curtain_left: ColorRect = ColorRect.new()
	var curtain_right: ColorRect = ColorRect.new()
	
	canvas.top_level = true
	
	curtain_left.size = Vector2(half_viewport_width, viewport_size.y)
	curtain_right.size = Vector2(half_viewport_width, viewport_size.y)
	curtain_right.global_position.x = half_viewport_width
	
	curtain_left.self_modulate = color
	curtain_right.self_modulate = color
	
	canvas.add_child.call_deferred(curtain_left)
	canvas.add_child.call_deferred(curtain_right)
	
	create_tween().tween_property(curtain_left, "global_position:x", -half_viewport_width, transition_time)
	create_tween().tween_property(curtain_right, "global_position:x", viewport_size.x, transition_time)
	
	await time.sleep(transition_time, callable)

func blink(canvas: Control, times: int = 2, color: Color = Color.BLACK):
	canvas.top_level = true
	
	for _i in range(times):
		var color_rect: ColorRect = ColorRect.new()
		
		color_rect.size = get_viewport_rect().size
		color_rect.self_modulate = color
		canvas.add_child(color_rect)
		
		var blink_sound_length: float = Audio.play_sound_and_return_length("blink")
		#var half_blink_sound_length: float = blink_sound_length / 2
		
		await time.sleep(blink_sound_length)
		color_rect.queue_free()
		await time.sleep(blink_sound_length)
