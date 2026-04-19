shader_type spatial;

uniform float speed = 2.0;
uniform float strength =  0.5;
void vertex() {
	//VERTEX.y += sin(TIME * speed ) * strength;
}

void fragment() {
	ALBEDO = COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
