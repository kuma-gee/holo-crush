/*
	動的電子背景シェーダー by あるる（きのもと 結衣） @arlez80
	Procedural Electric Background Shader by Yui Kinomoto @arlez80

	MIT License
*/
shader_type canvas_item;

uniform vec4 background_color : source_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform vec4 line_color : source_color = vec4( 0.0, 1.0, 1.0, 1.0 );
uniform float line_freq = 9.56;
uniform float height = 0.6;
uniform float speed = 0.8;
uniform vec2 scale = vec2( 2.0, 16.0 );
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D dissolve_texture;
uniform bool inverted = false;

void fragment( )
{
	vec2 uv = UV * scale;
	float shift = cos( floor( uv.y ) );
	uv.x += shift;

	float freq = clamp( cos( uv.x * line_freq ) * 3.0, 0.0, 1.0 ) * height;
	float line = 1.0 - clamp( abs( freq - mod( uv.y, 1.0 ) ) * 11.0, 0.0, 1.0 );

	COLOR = mix( background_color, line_color, line * mod( uv.x - TIME * speed * abs( shift ), 1.0) /*  * mod( TIME + shift, 1.0 ) */ );
	
	if (dissolve_amount < 0.0001 || dissolve_amount > 0.9999) {
		COLOR = vec4(COLOR.rgb, dissolve_amount);
	} else {
		float sample = texture(dissolve_texture, UV).r;
		if (inverted) {
			sample = 1.0 - sample;
		}
		COLOR = vec4(COLOR.rgb, smoothstep(0.0, sample, dissolve_amount));
	}
	
	
}
