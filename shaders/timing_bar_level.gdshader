shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float fade_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float noise_value = texture(noise_tex, UV).r;

	// Smooth fade using noise
	float alpha = smoothstep(fade_amount - 0.1, fade_amount + 0.1, noise_value);

	COLOR = tex_color;
	COLOR.a *= alpha;
}
