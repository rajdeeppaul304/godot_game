shader_type canvas_item;

uniform float flip_progress : hint_range(0.0, 1.0);
uniform bool horizontal_flip = true;

void fragment() {
    vec2 uv = UV;

    // Calculate flip scale and skew
    float flip = abs(flip_progress - 0.5) * 2.0; // 1 at ends, 0 at mid
    float scale = mix(1.0, 0.05, 1.0 - flip);    // Compress at midpoint
    float skew = (UV.y - 0.5) * (1.0 - flip) * 0.4;

    if (horizontal_flip) {
        uv.x = (uv.x - 0.5) * scale + 0.5 + skew;
    } else {
        uv.y = (uv.y - 0.5) * scale + 0.5 + skew;
    }

    // Color channel shift near midpoint
    float distortion_strength = smoothstep(0.4, 0.5, flip_progress) * smoothstep(0.6, 0.5, flip_progress);
    float offset = distortion_strength * 0.01; // Tiny offset for pixel art friendliness

    vec4 col;
    col.r = texture(TEXTURE, uv + vec2(offset, 0.0)).r;
    col.g = texture(TEXTURE, uv).g;
    col.b = texture(TEXTURE, uv - vec2(offset, 0.0)).b;
    col.a = texture(TEXTURE, uv).a;

    // Brightness dip and highlight shimmer
    float brightness = mix(1.0, 0.7, 1.0 - flip);
    float highlight = smoothstep(0.48, 0.5, flip_progress) * smoothstep(0.52, 0.5, flip_progress);
    col.rgb += highlight * 0.4;
    col.rgb *= brightness;

    COLOR = col;
}
