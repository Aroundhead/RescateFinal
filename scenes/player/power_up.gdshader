shader_type canvas_item;

uniform float time : hint_range(0.0, 10.0);
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_width = 0.1;
uniform float glow_strength = 1.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Diagonal from top-right to bottom-left
    float diagonal = UV.x + (1.0 - UV.y); // range ~ [0, 2]

    // Make it move over time → right to left
    float speed = 1.0;
    float glow_center = mod(time * speed, 2.0); // loop over diagonal range

    // Create a glowing band around the glow_center
    float glow = smoothstep(glow_center - glow_width, glow_center, diagonal) *
                 (1.0 - smoothstep(glow_center, glow_center + glow_width, diagonal));

    vec3 final_color = tex_color.rgb + glow * glow_color.rgb * glow_strength;

    COLOR = vec4(final_color, tex_color.a);
}
