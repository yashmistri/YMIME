shader_type spatial;


void fragment() {
    // Get the UV coordinates for the current pixel
    vec2 uv = UV;

    // Define two integer values
    int val1 = int(uv.x * 255.0); // Scale UV to get an integer
    int val2 = int(uv.y * 255.0); // Scale UV to get another integer

    // Perform a bitwise XOR operation
    int result = val1 ^ val2;

    // Map the result back to a color for visualization
    ALBEDO = vec3(float(result) / 255.0, float(result) / 255.0, float(result) / 255.0);
}