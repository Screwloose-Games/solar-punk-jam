shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 color : source_color = vec4(0,0,0,1);
uniform float size : hint_range(1.0, 1.5, 0.001) = 0 ;

void vertex() {
	VERTEX *= size;
}

void fragment() {
	discard;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
