shader_type canvas_item;

void fragment() {
	vec4 color = COLOR;
	color.a *= step(0.9, color.r);
	
	COLOR = color;
}
