shader_type canvas_item;

uniform int pixel_size : hint_range(1, 800) = 6;
uniform float curvature : hint_range(0.0, 0.25) = 0.08;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float vignette : hint_range(0.0, 1.0) = 0.35;
uniform float noise_amount : hint_range(0.0, 0.12) = 0.05;
uniform float brightness : hint_range(0.8, 1.5) = 1.08;
uniform float corner_round : hint_range(0.0, 0.15) = 0.06;

// In 2D canvas_item shaders, we use hint_screen_texture with sampler2D
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

vec2 curve(vec2 uv) {
    vec2 centered = uv * 2.0 - 1.0;
    float dist = dot(centered, centered);
    centered *= 1.0 + curvature * dist;
    return centered * 0.5 + 0.5;
}

void fragment() {
    // SCREEN_UV works perfectly in 2D screen shaders
    vec2 uv = SCREEN_UV;
    vec2 curved = curve(uv);
    
    // Soft edge mask
    vec2 edge = abs(curved - 0.5) * 2.0;
    float mask = 1.0 - smoothstep(1.0 - corner_round, 1.0, max(edge.x, edge.y));
    
    // Sample screen texture
    vec2 sample_uv = clamp(curved, 0.0, 1.0);
    vec2 pixel_uv = floor(sample_uv * float(pixel_size)) / float(pixel_size);
    
    // We read from the screen texture buffer
    vec3 color = texture(screen_texture, pixel_uv).rgb;
    
    // Apply mask
    color *= mask;
    
    // Scanlines (FRAGCOORD works in 2D as well!)
    float scan = sin(FRAGCOORD.y * 1.8) * 0.5 + 0.5;
    color *= 1.0 - scanline_intensity * scan;
    
    // Noise
    float noise = fract(sin(dot(uv + TIME * 0.5, vec2(12.9898, 78.233))) * 43758.5453);
    color += (noise - 0.5) * noise_amount;
    
    // Vignette
    float vig = 1.0 - vignette * length((uv - 0.5) * 1.6);
    color *= vig;
    
    color *= brightness;
    
    // In 2D, we output to COLOR instead of ALBEDO/ALPHA
    // We mix the calculated color with a solid 1.0 alpha, but multiply the edges by mask 
    // so the monitor corners turn completely black/transparent instead of showing raw game edges.
    COLOR = vec4(color, 1.0);
    
    // If you want the rounded screen corners to be solid black instead of cutting through to your desktop:
    if (mask < 0.1) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    }
}