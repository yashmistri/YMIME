shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform sampler2D curve;
uniform float scale=1.0;
void fragment() {
	vec2 uv2 = vec2(UV.x,0.0);
	float slope = texture(curve,uv2).r + 0.5;
	float b = -0.5*texture(curve,uv2).r + 0.5;
	//float slope = abs(UV.x*2.0-1.0)+0.5;
	//float b = -abs(UV.x*1.0-0.5)+0.25;
	vec2 warp_uv = vec2(UV.x,slope*UV.y+b);
	vec4 pixel_color = texture(TEXTURE, warp_uv);
	COLOR = pixel_color;
	COLOR.a = -0.1*texture(curve,uv2).r + 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
