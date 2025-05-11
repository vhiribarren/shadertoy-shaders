// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

const float SIGNAL_SIZE_PIXEL = 10.0;
const float SIGNAL_SPEED_X = 0.2;
const float SIGNAL_BLOOM_STRENGTH = 0.008;
const float SIGNAL_COLOR_SPREAD = 0.1;

const float SIGNAL_FREQ_BASE = 0.0;
const float SIGNAL_LACUNARITY = 1.0;
const int SIGNAL_HARMONICS = 8;

const vec3 SIGNAL_PALETTE_LUMINOSITY = vec3(0.5, 0.5, 0.5);
const vec3 SIGNAL_PALETTE_CONTRAST = vec3(0.5, 0.5, 0.5);
const vec3 SIGNAL_PALETTE_FREQUENCE = vec3(1.0, 1.0, 1.0);
const vec3 SIGNAL_PALETTE_PHASE = vec3(0.0, 0.33, 0.67);

const float PI = 3.14;

vec3 iq_color_palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    // https://iquilezles.org/articles/palettes/
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 signal_color(float unit_val) {
    return iq_color_palette(
        unit_val,
        SIGNAL_PALETTE_LUMINOSITY, SIGNAL_PALETTE_CONTRAST, SIGNAL_PALETTE_FREQUENCE, SIGNAL_PALETTE_PHASE);
}

float signal_shift_x(float uv_x) {
    return uv_x + SIGNAL_SPEED_X*iTime;
}

float random(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noisySignal(float t) {
    float signal = 0.0;
    float total_amp = 0.0;
    for (int i = 1; i <= SIGNAL_HARMONICS; ++i) {
        float freq = SIGNAL_FREQ_BASE + SIGNAL_LACUNARITY *  float(i);
        float phase = random(freq) * 2.0 * PI;
        float baseAmp = random(freq + 0.5);
        float timeMod = 0.5 + 0.5 * sin(iTime * 0.5 + freq);
        float amp = baseAmp * timeMod;
        signal += amp * sin(freq * t + phase);
        total_amp += amp;
    }
    return 0.9 * signal / float(total_amp);
}

float noisySignalDerivative( float x ) {
    const float h = 0.01;
    return (noisySignal(x+h) - noisySignal(x-h))/(2.0*h);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;
    uv = 2.0*(uv - 0.5) * vec2(iResolution.x/iResolution.y, 1.0);

    float pixelSize = 1.0 / iResolution.y;
    
    float shifted_x = signal_shift_x(uv.x);
    
    float signalDistance = abs(noisySignal(shifted_x) - uv.y);
    // https://iquilezles.org/articles/distance/
    float signalDistanceSlope = noisySignalDerivative(shifted_x);
    signalDistance /= sqrt( 1.0 + signalDistanceSlope*signalDistanceSlope );
    
    float signalCoeff = SIGNAL_BLOOM_STRENGTH / max(0.0001, (signalDistance - SIGNAL_SIZE_PIXEL*pixelSize + SIGNAL_BLOOM_STRENGTH));

    vec3 col = signalCoeff * signal_color(SIGNAL_COLOR_SPREAD*signal_shift_x(uv.x));

    fragColor = vec4(col,1.0);
}
