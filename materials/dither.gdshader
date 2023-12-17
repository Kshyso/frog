shader_type canvas_item;

uniform float saturation : hint_range(-1, 1) = -0.5; // Adjust this value to control the amount of saturation reduction
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    // Get the original color from the screen texture
    vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Calculate the luminance of the original color
    float luminance = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));

    // Interpolate between the original color and the grayscale version based on the saturation parameter
    vec3 final_color = mix(vec3(luminance), original_color.rgb, 1.0 + saturation);

    // Output the final color with the original alpha value
    COLOR = vec4(final_color, original_color.a);
}