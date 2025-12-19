shader_type canvas_item;
uniform sampler2D fog_mask;

void fragment() {
    float m = texture(fog_mask, UV).r;
    float a = 1.0 - m;  // 1 = hidden, 0 = revealed
    COLOR = vec4(0.0, 0.0, 0.0, a);
}