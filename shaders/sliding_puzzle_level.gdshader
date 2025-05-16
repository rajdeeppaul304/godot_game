shader_type canvas_item;

uniform float wipe_progress : hint_range(0.0, 1.0) = 0.0;
uniform int steps = 15;

void fragment() {
    float step_size = 1.0 / float(steps);
    float stepped_y = floor(UV.y / step_size) * step_size;
    
    if (stepped_y < wipe_progress) {
        COLOR = texture(TEXTURE, UV);
    } else {
        discard;
    }
}
