shader_type spatial;

uniform vec3 base_color : source_color = vec3(0.9, 0.9, 0.85);
uniform sampler2D noise_tex; // Use a fast noise texture here
uniform float grain_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // 1. Generate high-frequency grain
    float noise_val = texture(noise_tex, UV * 20.0).r; 
    
    // 2. Adjust the color slightly for "weathering"
    ALBEDO = base_color * (0.95 + noise_val * 0.05);
    
    // 3. Make it look rough and non-metallic
    ROUGHNESS = mix(0.6, 1.0, noise_val);
    METALLIC = 0.0;
    
    // 4. Apply grain to the Normal to catch the light
    NORMAL_MAP = vec3(0.5, 0.5, 1.0) + (noise_val * grain_strength * 0.1);
}