shader_type canvas_item;

uniform sampler2D background;

void fragment() {
	COLOR = texture(background, UV);
}