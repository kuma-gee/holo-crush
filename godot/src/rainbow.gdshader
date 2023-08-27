shader_type canvas_item;

uniform float speed = 1.0;
uniform float count = 5.0;
uniform float strength = 0.5;
uniform float smoothing = 0.5;
uniform float size = 2.0;
uniform vec2 scale = vec2(1, 1);
uniform sampler2D color_gradient;

void fragment() {
	vec4 color = COLOR;
	float time = TIME * speed;

	vec2 uv = (UV - vec2(0.5)) / vec2(size) * scale;
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);

	float opacity = sin(angle * count + time) * strength + smoothing;
	opacity *= smoothstep(0.0, 1.0, 1.0 - dist);

	COLOR = texture(color_gradient, vec2(dist, 0));
	COLOR.a *= opacity * color.a;
}