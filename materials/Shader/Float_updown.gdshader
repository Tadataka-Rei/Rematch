shader_type spatial;
uniform float speed = 2.0;
uniform float strength = 0.5;

void vertex() {
    float instance_offset = float(INSTANCE_ID) * 0.1; 
   
    float variation = mod(instance_offset, 1.0) * 0.5 + 0.75;

    VERTEX.y += sin((TIME + instance_offset) * speed * variation) * strength;
}