shader_type canvas_item;

uniform sampler2D clip_texture;
uniform vec2 clip_texture_size;
uniform vec2 clip_texture_offset;

void fragment(){
	COLOR=COLOR;
	
	vec2 texture_size = (1.0 / TEXTURE_PIXEL_SIZE);
	vec2 texture_ratio = texture_size / clip_texture_size;
	vec2 clip_UV = UV * texture_ratio + clip_texture_offset;
	
	vec4 color = COLOR;
	vec4 tex = texture(clip_texture, clip_UV);
	if (clip_UV.x > 1.0 || clip_UV.x < 0.0 || clip_UV.y > 1.0 || clip_UV.y < 0.0) {
		tex = vec4(0.0, 0.0, 0.0, 0.0);
	}
	float mix_tex = 1.0 - step(color.r, 1.0-tex.a);
	if (mix_tex == 0.0 && color.b > 0.0) {
		mix_tex = 1.0;
	}
	COLOR=vec4(mix(tex.rgb, color.rgb, mix_tex), color.a);

//	vec4 color;
//	if (clip_UV.x > 1.0 || clip_UV.x < 0.0 || clip_UV.y > 1.0 || clip_UV.y < 0.0) {
//		color = vec4(0.0, 0.0, 0.0, 0.0);
//	}
//	else {
//		color = texture(clip_texture, clip_UV);
//	}
//
//	if(color.a == 0.0)
//		COLOR=vec4(0.0, 0.0, 0.0, 0.0);
//	else
//		COLOR=color;
}