// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

const float SEGMENT_HEIGHT = 0.01;

// https://iquilezles.org/articles/distfunctions2d/
float sdSegment( in vec2 p, in vec2 a, in vec2 b ) {
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;

    vec3 col = vec3(0.0, 0.0, 0.0);

    // Simple segment
    float d1 = sdSegment(uv, vec2(0.25, 0.2), vec2(0.75, 0.2));
    d1 = 1.0 - step(SEGMENT_HEIGHT, d1);
    col += vec3(d1);

    // Bloom using inverse function
    float d2 = sdSegment(uv, vec2(0.25, 0.4), vec2(0.75, 0.4));
    float bloom_strength = 0.01;
    d2 = bloom_strength / (d2 - (SEGMENT_HEIGHT - bloom_strength));
    col += vec3(d2);

    // Bloom with smoothstep
    float d3 = sdSegment(uv, vec2(0.25, 0.6), vec2(0.75, 0.6));
    d3 = 1.0 - smoothstep(0.008, 0.05, d3);
    col += vec3(d3);

    // Bloom with an exponential function
    float d4 = sdSegment(uv, vec2(0.25, 0.8), vec2(0.75, 0.8));
    d4 = exp(-100.0 * (d4 - SEGMENT_HEIGHT));
    col += vec3(d4);

    fragColor = vec4(col, 1.0);
}
