shader_type canvas_item;

uniform sampler2D clip_texture;
uniform vec2 clip_texture_size;
uniform vec2 clip_texture_offset;
uniform vec4 background: source_color;
uniform float alpha_cutoff : hint_range(0.0, 1.0, 0.1) = 0.5;

void fragment() {
	vec2 texture_size = (1.0 / TEXTURE_PIXEL_SIZE);
	vec2 texture_ratio = texture_size / clip_texture_size;
	vec2 clip_UV = UV * texture_ratio + clip_texture_offset;

	vec4 color = COLOR;
	vec4 tex = texture(clip_texture, clip_UV);
	
	tex.a = step(alpha_cutoff, tex.a); // Clean up edges
	tex.rgb = mix(background.rgb, tex.rgb, step(0.01, tex.a)); // Set background for transparent pixels
	
	float mix_tex = smoothstep(0.1, 1.5, color.r); // Keep white border
	COLOR=vec4(mix(tex.rgb, color.rgb, mix_tex), color.a);
}