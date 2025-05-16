shader_type canvas_item;

uniform float fade : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (tex_color.a < 0.1) {
		discard;
	}

	float noise = texture(noise_texture, UV * 4.0).r;

	if (fade > noise) {
		discard;
	}

	COLOR = tex_color;
	COLOR.a *= 1.0 - fade;
}
