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
	
//	if (abs(dist.x) < 0.5 || abs(dist.y) < 0.5) {
//		COLOR = vec4(0.0);
//	} else {
	
//	float outer_radius = diameter / 2.0;
//	float inner_radius = outer_radius - thickness;
//	float outer_circle = step(length(pos), outer_radius);
//	float inner_circle = step(length(pos), inner_radius);
//
//
//	float angle = atan(pos.y, pos.x);
//	if (angle < 0.0) {
//	angle += 2.0 * PI;
//	}
//
//	float wave = 0.5 * sin(frequency * angle + phase) + 0.5;
//
//
//	float ring = outer_circle - inner_circle;
//	ring *= step(0.5, wave);
//	COLOR = vec4(color.rgb, ring * color.a);
}