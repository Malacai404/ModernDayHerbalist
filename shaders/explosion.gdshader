shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

uniform float progress = 0.0;
uniform float noise_scale = 5.0;
uniform float speed = 2.0;
uniform float glow = 4.0;

float hash(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    float n000 = hash(i + vec3(0,0,0));
    float n100 = hash(i + vec3(1,0,0));
    float n010 = hash(i + vec3(0,1,0));
    float n110 = hash(i + vec3(1,1,0));
    float n001 = hash(i + vec3(0,0,1));
    float n101 = hash(i + vec3(1,0,1));
    float n011 = hash(i + vec3(0,1,1));
    float n111 = hash(i + vec3(1,1,1));

    float nx00 = mix(n000, n100, f.x);
    float nx10 = mix(n010, n110, f.x);
    float nx01 = mix(n001, n101, f.x);
    float nx11 = mix(n011, n111, f.x);

    float nxy0 = mix(nx00, nx10, f.y);
    float nxy1 = mix(nx01, nx11, f.y);

    return mix(nxy0, nxy1, f.z);
}

void vertex() {
    float n = noise(NORMAL * noise_scale + vec3(TIME * speed));

    float expansion = progress * 1.8;

    VERTEX += NORMAL * ((n - 0.5) * 0.3 + expansion);
}

void fragment() {
    float n = noise(NORMAL * noise_scale + vec3(TIME * speed));

    vec3 cold = vec3(0.2, 0.02, 0.0);
    vec3 hot = vec3(1.0, 0.8, 0.3);

    vec3 fire = mix(cold, hot, smoothstep(0.2, 0.8, n));

    float fade = 1.0 - smoothstep(0.6, 1.0, progress);

    ALBEDO = fire;
    EMISSION = fire * glow * fade;
    ALPHA = fade;
}