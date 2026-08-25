shader_type canvas_item;

// Feed this from script: a texture where the RED channel holds
// normalized linear depth, 0.0 = near_dist, 1.0 = far_dist.
// (see setup notes for how to produce this from your 3D scene)
uniform sampler2D depth_tex : filter_nearest;

uniform float noise_scale : hint_range(1.0, 400.0) = 120.0;
uniform float density_curve : hint_range(0.1, 5.0) = 1.5;
uniform vec3 noise_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 bg_color : source_color = vec3(0.0, 0.0, 0.0);
uniform bool animate = true;
uniform float anim_speed : hint_range(0.0, 20.0) = 4.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	float depth01 = texture(depth_tex, UV).r; // 0 = near, 1 = far
	float density = 1.0 - clamp(depth01, 0.0, 1.0);
	density = pow(density, density_curve);

	vec2 uv = UV * noise_scale;
	if (animate) {
		uv += TIME * anim_speed;
	}
	float n = value_noise(uv);

	float mask = step(1.0 - density, n);

	COLOR.rgb = mix(bg_color, noise_color, mask);
	COLOR.a = mask;
}
