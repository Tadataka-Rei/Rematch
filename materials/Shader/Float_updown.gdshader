shader_type spatial;

uniform float speed = 2.0;
uniform float strength = 0.5;
uniform float rotation_speed = 0.2; 

// 2D rotation matrix
mat2 rotate2d(float angle) {
    return mat2(vec2(cos(angle), -sin(angle)),
                vec2(sin(angle), cos(angle)));
}

void vertex() {
    float instance_offset = float(INSTANCE_ID) * 0.1; 
    float variation = mod(instance_offset, 1.0) * 0.5 + 0.75;
    VERTEX.y += sin((TIME + instance_offset) * speed * variation) * strength;

    float angle = (TIME + instance_offset * 10.0) * rotation_speed * variation;
    
    VERTEX.xz = rotate2d(angle) * VERTEX.xz;
}

// color, similar to the floor because i like RENDERER_COMPATIBILITY
uniform vec4 ice_color : source_color = vec4(0.9, 0.95, 1.0, 0.4);
uniform float roughness : hint_range(0.0, 1.0) = 0.3;
uniform float specular_intensity : hint_range(0.0, 1.0) = 0.6;
uniform float edge_clarity : hint_range(0.0, 10.0) = 3.0; 

void fragment() {
    ALBEDO = ice_color.rgb;
    ROUGHNESS = roughness;
    SPECULAR = specular_intensity;
    METALLIC = 0.4; 
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), edge_clarity);
    
    ALPHA = mix(ice_color.a, 1.0, fresnel);
}