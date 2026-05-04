shader_type spatial;

uniform vec3 brick_color : source_color = vec3(0.5, 0.5, 0.5); // Default gray
uniform vec3 mortar_color : source_color = vec3(0.2, 0.2, 0.2);
uniform vec2 tiling = vec2(10.0, 15.0);
uniform float mortar_thickness : hint_range(0.01, 0.1) = 0.05;
uniform float roughness : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    // Scale the UVs
    vec2 uv = UV * tiling;
    
    uv.x += step(1.0, mod(uv.y, 2.0)) * 0.5;
    
    vec2 local_uv = fract(uv);
    
    float w = step(mortar_thickness, local_uv.x) * step(mortar_thickness, local_uv.y);
    
    vec3 final_color = mix(mortar_color, brick_color, w);
    
    ALBEDO = final_color;
    ROUGHNESS = roughness;
}