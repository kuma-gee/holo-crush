shader_type canvas_item;

uniform sampler2D background;

void fragment() {
	vec4 diff = vec4(1.0) - COLOR;
	COLOR = texture(background, UV);
	COLOR -= diff;
}