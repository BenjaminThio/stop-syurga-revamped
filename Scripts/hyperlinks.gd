extends HBoxContainer

#var texture_button_origin: Vector2 = Vector2.ZERO

@export var hovered_scale: float = 1.25
@export var hover_scale_transition_duration: float = 0.2

@onready var facebook: TextureButton = $ControlledFacebook/Facebook
@onready var instagram: TextureButton = $ControlledInstagram/Instagram
@onready var github: TextureButton = $ControlledGitHub/GitHub
@onready var youtube: TextureButton = $ControlledYouTube/YouTube

func _on_facebook_pressed():
	OS.shell_open("https://www.facebook.com/benjamin.thio.771")

func _on_instagram_pressed():
	OS.shell_open("https://www.instagram.com/benjamin_thio70")

func _on_github_pressed():
	OS.shell_open("https://github.com/BenjaminThio?tab=repositories")

func _on_you_tube_pressed():
	OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

func _on_mouse_entered_facebook():
	scale_up_texture_button(facebook)

func _on_mouse_exited_facebook():
	reset_texture_button_scale(facebook)

func _on_mouse_entered_instagram():
	scale_up_texture_button(instagram)

func _on_mouse_exited_instagram():
	reset_texture_button_scale(instagram)

func _on_mouse_entered_git_hub():
	scale_up_texture_button(github)

func _on_mouse_exited_git_hub():
	reset_texture_button_scale(github)

func _on_you_tube_mouse_entered():
	scale_up_texture_button(youtube)

func _on_you_tube_mouse_exited():
	reset_texture_button_scale(youtube)

func scale_up_texture_button(texture_button: TextureButton):
	"""
	texture_button_origin = texture_button.global_position
	
	var texture_button_distance_between_origin_and_center_point: Vector2 = texture_button.size * scale / 2
	var texture_button_center_point_global_position: Vector2 = texture_button_origin + texture_button_distance_between_origin_and_center_point
	var scaled_texture_button_distance_between_origin_and_center_point: Vector2 = texture_button_distance_between_origin_and_center_point * hovered_scale
	var scaled_texture_button_global_position: Vector2 = texture_button_center_point_global_position - scaled_texture_button_distance_between_origin_and_center_point
	"""
	var tween: Tween = create_tween()
	
	tween.tween_property(texture_button, "scale", Vector2.ONE * hovered_scale, hover_scale_transition_duration)
	#tween.parallel().tween_property(texture_button, "global_position", scaled_texture_button_global_position, hover_scale_transition_duration)

func reset_texture_button_scale(texture_button: TextureButton):
	var tween: Tween = create_tween()
	
	tween.tween_property(texture_button, "scale", Vector2.ONE, hover_scale_transition_duration)
	#tween.parallel().tween_property(texture_button, "global_position", texture_button_origin, hover_scale_transition_duration)
