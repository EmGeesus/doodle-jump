shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float force : hint_range(0.0, 0.2) = 0.05;
uniform float size : hint_range(0.0, 2.0) = 0.5;
uniform float thickness : hint_range(0.01, 1.0) = 0.1;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); 

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 scaledUV = (UV - center);
    float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    scaledUV.x *= ratio;

    float dist = length(scaledUV);
    
    float mask = smoothstep(size - thickness, size, dist) - smoothstep(size, size + thickness, dist);
   
    vec2 offset = normalize(scaledUV) * sin(dist * 40.0 - size * 50.0) * force * mask;
    
    vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
    
    float blend_amount = mask * tint_color.a;
    vec3 final_rgb = mix(screen_col.rgb, tint_color.rgb, blend_amount);
    
    COLOR = vec4(final_rgb, screen_col.a);
}
