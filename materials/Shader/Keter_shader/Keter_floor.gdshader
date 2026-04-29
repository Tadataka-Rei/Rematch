shader_type spatial;
render_mode blend_mix, depth_draw_always;
uniform vec4 ice_color : source_color = vec4(0.9, 0.95, 1.0, 0.4);
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float specular_intensity : hint_range(0.0, 1.0) = 0.8;
uniform float edge_clarity : hint_range(0.0, 5.0) = 3.0; // Controls the "sharpness" of the edges

void fragment() {
    ALBEDO = ice_color.rgb;
    ROUGHNESS = roughness;
    SPECULAR = specular_intensity;
    METALLIC = 0.1; 
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), edge_clarity);
    
    // 3. Transparency
    // The edges stay crisp and opaque, while the center is clear
    ALPHA = mix(ice_color.a, 1.0, fresnel);
}