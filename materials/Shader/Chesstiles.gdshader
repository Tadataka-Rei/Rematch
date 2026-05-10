shader_type spatial;

uniform float speed = 7;
uniform float strength =  1;
uniform float upto = 19;
void vertex() {
	float movement = TIME * speed * strength;
    float final_offset = min(movement, upto);
    
    VERTEX.y += final_offset;
}

void fragment() {
	ALBEDO = COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
