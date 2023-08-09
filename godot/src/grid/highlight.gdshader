shader_type canvas_item;

uniform float frequency = 10.0; // Controls the number of dots
uniform float phase = 0.0; // Controls the rotation of the circle

uniform float size = 0.05;
uniform float speed = 1.0;

void fragment() {
	vec2 center = vec2(0.5);
	vec2 dist = UV - center;
	
	float threshold = 0.5 - size;
	float d = max(abs(dist.x), abs(dist.y));
	float a = 1.0 * smoothstep(size, 0.55, d);
	
	float angle = atan(dist.y, dist.x);
	if (angle < 0.0) {
		angle += 2.0 * PI;
	}
	float wave = 0.5 * sin(frequency * angle + TIME * speed) + 0.5;
	
	COLOR = COLOR;
	COLOR.a *= a * wave; // smoothstep(0.3, 0.5, wave);
}