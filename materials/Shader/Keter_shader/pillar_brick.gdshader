shader_type spatial;

uniform vec3 base_color : source_color = vec3(0.95, 0.95, 1.0); // Off-white
uniform vec3 crack_color : source_color = vec3(0.3, 0.3, 0.4); // Darker gray for deep cracks
uniform sampler2D noise_texture : repeat_enable;

uniform float crack_threshold : hint_range(0.0, 1.0) = 0.6;
uniform float crack_width : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    // Sample the noise texture
    float noise_val = texture(noise_texture, UV).r;
    
    float crack_mask = smoothstep(crack_threshold - crack_width, crack_threshold, noise_val) -
                       smoothstep(crack_threshold, crack_threshold + crack_width, noise_val);
    
    ALBEDO = mix(base_color, crack_color, crack_mask);
    METALLIC = 0.0;
    ROUGHNESS = 0.8;
    
    // Add depth to cracks by pushing the normals slightly
    NORMAL = normalize(mix(NORMAL, vec3(0.0, 0.0, 1.0), crack_mask * 0.5));
}