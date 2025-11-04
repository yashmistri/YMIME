shader_type spatial;
render_mode world_vertex_coords;
uniform float precision = 10.0;

float snap(float p) {
	return trunc(p);
}

void vertex() {
	// Called for every vertex the material is visible on.
	//VERTEX = round(VERTEX*precision)/precision;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
