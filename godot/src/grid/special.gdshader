shader_type canvas_item;

uniform float size = 0.5;
uniform float speed = 1.0;

uniform bool top = true;
uniform bool left = true;
uniform bool right = true;
uniform bool bot = true;

void fragment() {
	vec2 center = vec2(0.5);
	vec2 dist = UV - center;

	bool is_right = right && dist.x > 0.0;
	bool is_left = dist.x < 0.0 && left;
	bool is_bot = bot && dist.y > 0.0;
	bool is_top = dist.y < 0.0 && top;
	float d = max(is_right || is_left ? abs(dist.x) : 0.0, is_bot || is_top ? abs(dist.y) : 0.0);
	float a = 1.0 * smoothstep(size, 0.55, d);
	
	COLOR = COLOR;
	COLOR.a *= a;
}