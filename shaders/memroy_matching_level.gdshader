shader_type canvas_item;

uniform float wipe_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    if ((1.0 - UV.x) < wipe_progress) {
        COLOR = texture(TEXTURE, UV);
    } else {
        discard;
    }
}
