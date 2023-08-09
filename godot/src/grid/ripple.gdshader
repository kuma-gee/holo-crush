shader_type canvas_item;

uniform float speed = 1.0;
uniform vec4 primary_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 secondary_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float turbulence = 0.2;
uniform float distortion = 0.1;

void fragment() {
    float time = TIME * speed;
    
    vec2 uv = (UV - vec2(0.5)) * vec2(2.0);
    float dist = length(uv);
    
    // Calcola un effetto di onda concentrica sull'opacità
    float opacity = sin(dist * 10.0 - time) * 0.5 + 0.5;
    
    // Applica una modulazione in base alla distanza dal centro
    opacity *= smoothstep(0.0, 1.0, 1.0 - dist);
    
    // Applica il colore primario e il colore secondario in base all'angolo
    vec4 color = mix(primary_color, secondary_color, abs(sin(time)));
    
    // Applica un effetto di turbolenza al UV
    uv += vec2(sin(uv.y * turbulence + time), cos(uv.x * turbulence + time)) * distortion;
    
    // Applica una distorsione alla coordinata UV in base alla turbolenza
    vec2 distorted_uv = uv + vec2(sin(uv.y * turbulence + time), cos(uv.x * turbulence + time)) * distortion;
    
    // Calcola il colore finale basato sul colore e sulla distorsione
    vec4 final_color = mix(color, vec4(1.0), length(distorted_uv));
    
    COLOR = vec4(final_color.rgb, final_color.a * opacity);
}