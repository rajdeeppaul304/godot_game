shader_type canvas_item;

uniform float grey_amount : hint_range(0.0, 1.0) = 1.0;
uniform float blur_amount : hint_range(0.0, 5.0) = 0.2;

void fragment() {
    vec2 size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel = SCREEN_UV * size;

    // Simple blur kernel (3x3 box blur)
    vec4 color = vec4(0.0);
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_amount / size;
            color += texture(TEXTURE, UV + offset);
        }
    }
    color /= 9.0;

    // Convert to greyscale
    float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 greyscale_color = vec3(grey);

    // Mix original (blurred) color with greyscale
    COLOR = vec4(mix(color.rgb, greyscale_color, grey_amount), color.a);
}
