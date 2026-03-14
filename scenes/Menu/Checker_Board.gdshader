shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(1.0);
uniform vec4 color_b : source_color = vec4(0.0);
uniform float tiles = 10.0;
uniform vec2 direction = vec2(0.5, 0.2); // movement direction
uniform float speed = 0.1; 

void fragment() {

    vec2 animated_uv = UV + direction * TIME * speed;

    vec2 grid = floor(animated_uv * tiles);
    float checker = mod(grid.x + grid.y, 2.0);

    COLOR = mix(color_a, color_b, checker);
}