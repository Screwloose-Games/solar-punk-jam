shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform int blur_radius : hint_range(1, 16) = 8;
uniform float vertical_blur_scale : hint_range(0.0, 10.0) = 1.0;    // Controls vertical blur intensity
uniform float horizontal_blur_scale : hint_range(0.0, 10.0) = 0.0;  // New: controls horizontal blur intensity, default off

uniform float darkness : hint_range(0.0, 10.0) = 0.8;

uniform int fade_direction : hint_range(0, 3) = 0;
uniform float fade_cutoff : hint_range(0.0, 1.0) = 0.2;
uniform float fade_intensity : hint_range(0.1, 10.0) = 2.0;

// Precomputed Gaussian weights for radius 16, sigma ≈ 8
const float weights[17] = float[](
    0.196482, 0.175713, 0.121703, 0.066143, 0.028532,
    0.009909, 0.002798, 0.000654, 0.000126, 0.000020,
    0.000002, 0.000000, 0.000000, 0.000000, 0.000000,
    0.000000, 0.000000
);

float calculate_fade(vec2 uv) {
    float fade = 0.0;
    if (fade_direction == 0) fade = uv.x;
    else if (fade_direction == 1) fade = 1.0 - uv.x;
    else if (fade_direction == 2) fade = uv.y;
    else fade = 1.0 - uv.y;

    if (fade < fade_cutoff) return 1.0;
    fade = (fade - fade_cutoff) / (1.0 - fade_cutoff);
    return clamp(pow(1.0 - fade * 2.0, fade_intensity), 0.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 _source_color = texture(SCREEN_TEXTURE, uv); // Fetch original color once

    vec4 blurred_effect_color; // This will hold the color after blur operations

    bool apply_vertical_blur = vertical_blur_scale > 0.001;    // Check if vertical blur is active (using a small epsilon)
    bool apply_horizontal_blur = horizontal_blur_scale > 0.001; // Check if horizontal blur is active (using a small epsilon)

    if (!apply_vertical_blur && !apply_horizontal_blur) {
        blurred_effect_color = _source_color; // No blur active, use the original source color
    } else {
        vec4 accumulated_blur_value = vec4(0.0);
        int num_active_blur_directions = 0;

        // Perform vertical blur if active
        if (apply_vertical_blur) {
            vec4 vertical_pass_result = _source_color * weights[0]; // Start with the central pixel's contribution for this direction
            vec2 vertical_offset_step = vec2(0.0, SCREEN_PIXEL_SIZE.y * vertical_blur_scale);
            for (int i = 1; i <= blur_radius; i++) {
                float weight = weights[i];
                // The loop is bound by blur_radius, which uses the relevant portion of the weights array.
                // No additional break/continue needed unless extreme profiling suggests it for specific weight distributions.
                vec2 current_shift = vertical_offset_step * float(i);
                vertical_pass_result += texture(SCREEN_TEXTURE, uv + current_shift) * weight;
                vertical_pass_result += texture(SCREEN_TEXTURE, uv - current_shift) * weight;
            }
            accumulated_blur_value += vertical_pass_result;
            num_active_blur_directions++;
        }

        // Perform horizontal blur if active
        if (apply_horizontal_blur) {
            vec4 horizontal_pass_result = _source_color * weights[0]; // Start with the central pixel's contribution for this direction
            vec2 horizontal_offset_step = vec2(SCREEN_PIXEL_SIZE.x * horizontal_blur_scale, 0.0);
            for (int i = 1; i <= blur_radius; i++) {
                float weight = weights[i];
                vec2 current_shift = horizontal_offset_step * float(i);
                horizontal_pass_result += texture(SCREEN_TEXTURE, uv + current_shift) * weight;
                horizontal_pass_result += texture(SCREEN_TEXTURE, uv - current_shift) * weight;
            }
            accumulated_blur_value += horizontal_pass_result;
            num_active_blur_directions++;
        }

        // Combine results from active blur directions
        if (num_active_blur_directions == 2) {
            // Both vertical and horizontal blurs were performed.
            // Each pass (vertical_pass_result, horizontal_pass_result) independently included the (source_color * weights[0]) term.
            // To correctly represent a cross-shaped kernel where the center is effectively counted once with weights[0],
            // we subtract one of these (source_color * weights[0]) contributions from the sum.
            blurred_effect_color = accumulated_blur_value - (_source_color * weights[0]);
        } else {
            // Only one blur direction was active (num_active_blur_directions == 1).
            // accumulated_blur_value already holds the correct result from that single pass
            // (which includes the source_color * weights[0] term once).
            blurred_effect_color = accumulated_blur_value;
        }
    }

    // Apply darkness modifier to the RGB channels of the (potentially) blurred color
    blurred_effect_color.rgb *= darkness;

    // Calculate fade amount and mix the original source color with the blurred color
    float fade_value = calculate_fade(uv);
    vec4 final_mixed_color = mix(_source_color, blurred_effect_color, fade_value);
    
    // Ensure final alpha is 1.0, consistent with the original shader's behavior
    final_mixed_color.a = 1.0;

    COLOR = final_mixed_color;
}