shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform sampler2D noise_tex : source_color;
uniform vec4 tint_color : source_color = vec4(1.0);


void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float n = texture(noise_tex, UV).r;
	if (n < progress) {
        discard;
    }
	
	COLOR = tint_color * COLOR;
	
    

    //COLOR = tex;
}
