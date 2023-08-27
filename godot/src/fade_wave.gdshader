shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float scale: hint_range(0.0, 2.0, 0.01) = 1.0;

uniform sampler2D mask;

vec2 scale_uv(vec2 uv, vec2 origin, vec2 scale_factor)
{
	vec2 scaled_coord = uv - origin;
	mat2 s = mat2(vec2(scale_factor.x, 0.0), vec2(0.0, scale_factor.y));
	scaled_coord *= s;
	scaled_coord += origin;
	return scaled_coord;
}

void fragment() {
	vec2 uv = scale_uv(UV, center, vec2(scale, scale));
	vec4 color = texture(mask, uv);
	if (uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0) {
		color = vec4(0.0);
	}
	
	COLOR=vec4(step(1.0, color.r) * color.a * step(0.0, UV.y));
}
