shader_type canvas_item;

uniform float speed = 1.0;
uniform float count = 5.0;
uniform float strength = 0.5;
uniform float smoothing = 0.5;
uniform float size = 2.0;
uniform sampler2D color_gradient;

void fragment() {
	float time = TIME * speed;

	vec2 uv = (UV - vec2(0.5)) / vec2(size);
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);

	float opacity = sin(angle * count + time) * strength + smoothing;
	//opacity = step(0.5, opacity);
	opacity *= smoothstep(0.0, 1.0, 1.0 - dist);
	
	COLOR.rgb = texture(color_gradient, vec2(dist, 0)).rgb;
	COLOR.a *= opacity;
}