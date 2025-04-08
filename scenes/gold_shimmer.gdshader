shader_type canvas_item;

uniform float sparkle_strength : hint_range(0.0, 1.0) = 0.5;  // Adjust sparkle strength
uniform float sparkle_speed : hint_range(0.0, 10.0) = 1.0;   // Speed of shimmer
uniform float white_threshold : hint_range(0.0, 1.0) = 0.95;  // Threshold to detect white pixels

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    if (base_color.r > white_threshold && base_color.g > white_threshold && base_color.b > white_threshold) {
        COLOR = base_color;
    } else {

        vec3 gold1 = vec3(1.0, 0.95, 0.0);
        vec3 gold2 = vec3(1.0, 0.9, 0.0);
        vec3 gold3 = vec3(0.95, 0.8, 0.1);
        vec3 gold4 = vec3(0.9, 0.7, 0.2);


        float cycle_time = fract(TIME * sparkle_speed);


        vec3 final_gold;
        if (cycle_time < 0.25) {
            final_gold = mix(gold1, gold2, cycle_time * 4.0);
        } else if (cycle_time < 0.5) {
            final_gold = mix(gold2, gold3, (cycle_time - 0.25) * 4.0);
        } else if (cycle_time < 0.75) {
            final_gold = mix(gold3, gold4, (cycle_time - 0.5) * 4.0);
        } else {
            final_gold = mix(gold4, gold1, (cycle_time - 0.75) * 4.0);
        }
        vec3 mixed_color = mix(base_color.rgb, final_gold, sparkle_strength);
        COLOR = vec4(mixed_color, base_color.a);
    }
}