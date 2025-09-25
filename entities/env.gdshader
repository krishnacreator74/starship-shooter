shader_type canvas_item;

uniform vec2 resolution = vec2(600.0, 400.0);

// Noise texture (use a black/white noise image)
uniform sampler2D noise_texture : hint_albedo;

// Number of stars per area
uniform float density : hint_range(1.0, 100.0, 0.1) = 20.0;

// Control speed of stars (x and y direction)
uniform float speed_x : hint_range(-100.0, 100.0, 0.1) = 20.0;
uniform float speed_y : hint_range(-100.0, 100.0, 0.1) = 0.0;

// How many layers of stars (parallax depth)
uniform float layers : hint_range(1.0, 10.0, 1.0) = 3.0;

void fragment() {
    vec2 uv = UV;
    uv.x *= resolution.x / resolution.y; // keep aspect ratio

    vec2 speed = TIME * vec2(speed_x, speed_y) * 0.01;

    float stars = 0.0;

    for (float i = 0.0; i < layers; i += 1.0) {
        float shift = i * 0.2;          // move each layer slightly
        float brightness = 1.0 - i * 0.2; // further layers are dimmer

        stars += step(
            1.0 - density * 0.01,
            pow(texture(noise_texture, uv + speed + vec2(shift)).r, 50.0)
        ) * brightness;
    }

    COLOR = vec4(vec3(stars), 1.0);
}
