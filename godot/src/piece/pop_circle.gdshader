// https://godotshaders.com/shader/unit-selected-oscillating-circle/
shader_type canvas_item;

uniform float ring_radius : hint_range(0.1, 0.5, 0.01) = 0.4;
uniform float thickness_scalar : hint_range(0.0, 0.99, 0.05) = 0.7;
uniform vec4 color : source_color = vec4(1.0,1.0,1.0,1.0);
uniform float progress : hint_range(-1.0, 1.0, 0.01) = 0.0;

float range_lerp(float value, float min1, float min2, float max1, float max2){
	return min2 + (max2 - min2) * ((value - min1) / (max1 - min1));
}

void fragment() {
	// Calculate the distance between the current pixel and the center of the unit
	float dist = distance(UV, vec2(0.5, 0.5));
	
	if (dist <= ring_radius) {
		float ring_size = ring_radius + progress;
		float alpha = step(dist, ring_size) * smoothstep(ring_size * (1.0 - thickness_scalar), ring_size, dist);
		
		if (alpha == 0.0 && dist > ring_size) {
			COLOR = vec4(0.0);
		} else {
			float w = range_lerp(alpha, 0.0, 1.0, 1.0, 0.0);
			COLOR = vec4(mix(color.rgb, COLOR.rgb, w), 1.0);
		}
	} else {
		COLOR = COLOR;
	}
}