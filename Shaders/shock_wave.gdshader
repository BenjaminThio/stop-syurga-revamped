shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec2 center;
uniform float force;

void fragment() {
	vec2 disp = normalize(UV - center) * force;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}
