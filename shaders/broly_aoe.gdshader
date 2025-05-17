shader_type canvas_item;

uniform float reveal_radius : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center_uv = vec2(0.5, 0.5); // Center of the AOE texture

void fragment() {
	vec2 uv = UV;
	float dist = distance(uv, center_uv);

	// This time: keep the pixels inside the radius, and hide those outside
	float mask = smoothstep(reveal_radius, reveal_radius + 0.05, dist);

	vec4 tex_color = texture(TEXTURE, uv);
	tex_color.a *= (1.0 - mask); // Reveal center outward

	COLOR = tex_color;
}
