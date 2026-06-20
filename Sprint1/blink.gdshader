shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 1.0;
uniform float blur_size : hint_range(0.001, 0.5) = 0.1;

void fragment() {
    vec2 center = vec2(0.5, 0.5);

    float dist = distance(UV, center);

    float alpha = smoothstep(
        radius - blur_size,
        radius,
        dist
    );

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}