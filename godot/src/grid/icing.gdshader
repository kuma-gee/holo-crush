shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float smoothness : hint_range(0.0, 1.0, 0.01) = 1.0;

uniform float border_width : hint_range(0.0, 0.2, 0.01) = 0.01;
uniform float border_smoothness : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	vec4 color = COLOR;
	vec2 v = vec2(.5) - UV;
	float d = length(v);
	float a = color.a * smoothstep(radius - smoothness, radius, d);
	
	float startLarge = 1.0 - border_width;
	float startSmall = 0.0 - border_width;
	
	float border = smoothstep(startLarge - border_smoothness, startLarge + border_smoothness, UV.x) 
		+ smoothstep(startLarge - border_smoothness, startLarge + border_smoothness, UV.y) 
		+ smoothstep(startSmall - border_smoothness, startSmall + border_smoothness, -UV.x) 
		+ smoothstep(startSmall - border_smoothness, startSmall + border_smoothness, -UV.y);
	float x = 1.0 * clamp(border, 0.0, 1.0);
	
	COLOR = color;
	COLOR.a = a + x;
}