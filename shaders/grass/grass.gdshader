shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

uniform vec3 player_pos = vec3(0.0);
uniform float interact_power = 0.5;
uniform float radius = 1.0;

varying vec3 worldPos;

//void vertex() {
	//worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
//}

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // model space to world space
	vec3 direction = worldPos - player_pos;
	direction.y = 0.0;
	direction = normalize(direction);
	float dist = distance(player_pos, worldPos);
	float power = smoothstep(radius, 0.0, dist);
	direction = (vec4(direction, 1.0) * MODEL_MATRIX).xyz; // world space direction to model space
	VERTEX += direction * power * interact_power * (1.0 - UV.y);
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color, color2, 1.0- UV.y) * mix(color, color2, noiseLevel.r);
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}