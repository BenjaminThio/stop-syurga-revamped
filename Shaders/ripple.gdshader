shader_type canvas_item;

uniform float SPEED = 20.0;
uniform float RTIME = 0.0;
uniform vec4 drop0 = vec4(0.4,0.4,1,0);
uniform vec4 drop1 = vec4(0.4,0.4,1,0);
uniform vec4 drop2 = vec4(0.4,0.4,1,0);
uniform vec4 drop3 = vec4(0.4,0.4,1,0);
uniform vec4 drop4 = vec4(0.4,0.4,1,0);
uniform vec4 drop5 = vec4(0.4,0.4,1,0);
uniform vec4 drop6 = vec4(0.4,0.4,1,0);
uniform vec4 drop7 = vec4(0.4,0.4,1,0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec2 riple(vec4 drop, vec2 uv){
	vec2 uvdrop = (uv - drop.xy) * vec2(1.77, 1.0);	
	float rtime = RTIME - drop.a;
	float dist = sqrt(uvdrop.x*uvdrop.x+uvdrop.y*uvdrop.y);	
	float rh = sin(dist*100.0/drop.z - RTIME*SPEED);
	float prop_dist = rtime* SPEED/100.0;
	float prop_factor = smoothstep(prop_dist, prop_dist - 0.05, dist);
	prop_factor *= smoothstep(prop_dist-0.3*drop.z, prop_dist, dist);
	prop_factor /= rtime;
	rh *= prop_factor;
	return normalize(uvdrop)*rh;
}

void fragment(){
	COLOR.rgb = vec3(0.0);
	
	vec2 riple_offset = riple(drop0, UV); 
	riple_offset += riple(drop1, UV); 
	riple_offset += riple(drop2, UV); 
	riple_offset += riple(drop3, UV); 
	riple_offset += riple(drop4, UV); 
	riple_offset += riple(drop5, UV); 
	riple_offset += riple(drop6, UV); 
	riple_offset += riple(drop7, UV); 
	
	COLOR = textureLod(TEXTURE, UV + riple_offset * 0.01, 0);
}