shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.5;

uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(90.0, 180.0, 0.1) = 45.0;


float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
	COLOR = COLOR;
	
	float slope = tan(radians(shine_angle));
	float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope);
    float shine = step(slope * UV.x - UV.y, progress) - step(slope * UV.x - UV.y, progress + shine_size + shine_size * slope);
    COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
	
	COLOR.a *= step(UV.x, dissolve_amount);
	
//	if (dissolve_amount < 0.0001 || dissolve_amount > 0.9999) {
//		COLOR = vec4(COLOR.rgb, dissolve_amount);
//	} else {
//		COLOR = vec4(COLOR.rgb, step(UV.x, dissolve_amount));
//	}
}
