shader_type canvas_item;

uniform float time;
uniform float max_radius = 20.0;
uniform float fade_time = 3.0;
uniform vec4 explosion_color : source_color = vec4(1.0, 0.6, 0.1, 1.0);

float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 pos) {
	vec2 i = floor(pos);
	vec2 f = fract(pos);
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float radius = time * max_radius;
	float dist = length(uv);

	float n = noise(UV * 10.0 + vec2(time));
	float edge = smoothstep(radius + 0.1 + n * 0.1, radius - 0.1, dist);

	float alpha = 1.0 - time / fade_time;
	COLOR = explosion_color * edge * alpha;
}