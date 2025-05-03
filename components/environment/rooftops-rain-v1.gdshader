shader_type canvas_item;

#define iResolution 1.0/SCREEN_PIXEL_SIZE
#define iTime TIME
#define fragColor COLOR

uniform float frequency : hint_range(-10.0, 4.0, 0.1) = 0.0;
uniform float size : hint_range(0.001, 0.05, 0.001) = 0.015;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float vignette_radius : hint_range(0.0, 0.8, 0.01) = 0.3;
uniform float vignette_smoothness : hint_range(0.0, 0.5, 0.01) = 0.2;


// Author: Élie Michel
// License: CC BY 3.0
// July 2017

vec2 rand(vec2 c){
    mat2 m = mat2(vec2(12.9898,.16180),vec2(78.233,.31415));
    return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}

vec2 noise(vec2 p){
    vec2 co = floor(p);
    vec2 mu = fract(p);
    mu = 3.*mu*mu-2.*mu*mu*mu;
    vec2 a = rand((co+vec2(0.,0.)));
    vec2 b = rand((co+vec2(1.,0.)));
    vec2 c = rand((co+vec2(0.,1.)));
    vec2 d = rand((co+vec2(1.,1.)));
    return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
}

void fragment()
{
    // --- Vignette Calculation ---
    vec2 center = vec2(0.5, 0.5);
    float dist = length(UV - center);

    float vignette_intensity = smoothstep(vignette_radius, vignette_radius + vignette_smoothness, dist);

    // --- Original Effect Calculation ---
    vec2 u = UV;
    vec2 v_noise_input = UV * 0.1;
    vec2 n = noise(v_noise_input*200.);

    vec4 base_color = textureLod(screen_texture, u, 2.5);
    vec4 effect_color = base_color;

    // Loop through the different inverse sizes of drops
    for (float r = 4. ; r > frequency ; r--) {
        vec2 x = iResolution.xy * r * size;
        vec2 p = 6.28 * u * x + (n - .5) * 2.;
        vec2 s = sin(p);

        // Current drop properties.
        vec2 v_drop_lookup = round(u * x - 0.25) / x;
        vec4 d = vec4(noise(v_drop_lookup*200.), noise(v_drop_lookup));

        // Drop shape and fading
        float t = (s.x+s.y) * max(0., 1. - fract(iTime * (d.b + .1) + d.g) * 2.);;

        // d.r -> only x% of drops are kept on, with x depending on the size of drops
        if (d.r < (5.-r)*.08 && t > .5) {
            // Drop normal
            vec3 v_normal = normalize(-vec3(cos(p), mix(.2, 2., t-.5))); // Renamed original 'v' inside if

            // Poor man's refraction (no visual need to do more)
            effect_color = texture(screen_texture, u - v_normal.xy * .3);
        }
    }

    // --- Final Color Calculation ---
    COLOR = mix(base_color, effect_color, vignette_intensity);

    // Debug noise function
    //COLOR = vec4(n, 0.0, 1.0);
    // Debug vignette mask
    //COLOR = vec4(vec3(vignette_intensity), 1.0);
}
