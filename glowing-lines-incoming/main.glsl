// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

const int BEAM_COUNT = 10;
const float BEAM_RADIUS = 0.05;
const vec3 BEAM_PALETTE_LUMINOSITY = vec3(0.5, 0.5, 0.5);
const vec3 BEAM_PALETTE_CONTRAST = vec3(0.5, 0.5, 0.5);
const vec3 BEAM_PALETTE_FREQUENCE = vec3(1.0, 1.0, 1.0);
const vec3 BEAM_PALETTE_PHASE = vec3(0.0, 0.33, 0.67);
const float BEAM_DEPTH_Z_BIRTH = 100.0;
const float BEAM_DEPTH_Z_DEATH = -2.0;
const float BEAM_DEPTH_DISTANCE = abs(BEAM_DEPTH_Z_DEATH - BEAM_DEPTH_Z_BIRTH);
const float BEAM_SPEED = 1.0;
const float BEAM_FADE_END_DISTANCE = 10.0;
const float BEAM_BLOOM_INTENSITY = 0.5;

const int RAYMARCH_STEPS_MAX = 100;
const float RAYMARCH_RADIUS_MIN = 0.01;
const float RAYMARCH_RADIUS_MAX = 200.0;
const vec3 EYE_POSITION = vec3(0.0, 0.0, -1.0);
const float MAX_F32 = 3.402823466e+38;

float random_f32(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 random_vec2(vec2 uv) {
    float x = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    float y = fract(sin(dot(uv, vec2(39.3467, 11.135))) * 96321.5647);
    return vec2(x, y);
}

vec3 iq_color_palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    // https://iquilezles.org/articles/palettes/
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 beam_color(float unit_val) {
    return iq_color_palette(
        unit_val,
        BEAM_PALETTE_LUMINOSITY, BEAM_PALETTE_CONTRAST, BEAM_PALETTE_FREQUENCE, BEAM_PALETTE_PHASE);
}

float sd_infinite_cylinder(vec3 p, vec3 pos, vec3 dir, float radius) {
    vec3 d = normalize(dir);
    vec3 pa = p - pos;
    vec3 projected = pa - dot(pa, d) * d;
    return length(projected) - radius;
}

struct BeamScanInfo {
    vec3 color;
    float distance;
};

struct BeamMinInfo {
    vec3 color;
    float min_from_ray;
    vec3 coords;
};

BeamScanInfo scene(vec3 p, int beam_idx) {
    float beam_phase = random_f32(vec2(0.0, float(beam_idx))) * BEAM_DEPTH_DISTANCE;
    float beam_total_distance = iTime * BEAM_SPEED + beam_phase;
    float beam_segment = floor(beam_total_distance / BEAM_DEPTH_DISTANCE);
    float beam_z_pos = BEAM_DEPTH_Z_BIRTH - mod(beam_total_distance, BEAM_DEPTH_DISTANCE);
    vec3 beam_dir = vec3(1.0 - 2.0 * random_vec2(vec2(beam_segment, float(beam_idx))), 0.0);
    vec2 beam_shift = 10.0 * (1.0 - 2.0 * random_vec2(vec2(beam_segment + 1.0, float(beam_idx))));
    return BeamScanInfo(
        beam_color(random_f32(vec2(beam_segment, float(beam_idx)))),
        sd_infinite_cylinder(p, vec3(beam_shift, beam_z_pos), beam_dir, BEAM_RADIUS)
    );
}

float bloom_coeff(float distance) {
    return max(BEAM_BLOOM_INTENSITY / (distance + 0.05) - 0.05, 0.0);
}

vec3 raymarch(vec3 start_pos, vec3 direction) {
    int i = 0;
    BeamMinInfo min_distances[BEAM_COUNT];
    for (int obj_idx = 0; obj_idx < BEAM_COUNT; obj_idx++) {
        min_distances[obj_idx] = BeamMinInfo(vec3(0.0), MAX_F32, vec3(0.0));
    }
    float total_distance = 0.0;
    while (i < RAYMARCH_STEPS_MAX) {
        vec3 scan_pos = start_pos + total_distance * direction;
        float next_hop = 1e38;
        int nearest_obj_idx = -1;
        for (int obj_idx = 0; obj_idx < BEAM_COUNT; obj_idx++) {
            BeamScanInfo scanned_obj = scene(scan_pos, obj_idx);
            if (scanned_obj.distance < min_distances[obj_idx].min_from_ray) {
                min_distances[obj_idx] = BeamMinInfo(scanned_obj.color, scanned_obj.distance, scan_pos);
            }
            if (scanned_obj.distance < next_hop) {
                next_hop = scanned_obj.distance;
                nearest_obj_idx = obj_idx;
            }
        }
        total_distance += next_hop;
        if (next_hop < RAYMARCH_RADIUS_MIN || total_distance > RAYMARCH_RADIUS_MAX) {
            break;
        }
        i++;
    }
    vec3 color = vec3(0.0, 0.0, 0.0);
    for (int obj_idx = 0; obj_idx < BEAM_COUNT; obj_idx++) {
        float fade_coeff = smoothstep(BEAM_DEPTH_Z_BIRTH, BEAM_DEPTH_Z_BIRTH - BEAM_FADE_END_DISTANCE, min_distances[obj_idx].coords.z);
        color += fade_coeff * min_distances[obj_idx].color * bloom_coeff(min_distances[obj_idx].min_from_ray);
    }
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv = uv * vec2(iResolution.x/iResolution.y, 1.0);
    vec3 eye = EYE_POSITION;
    vec3 canvas = vec3(uv, 0.0);
    vec3 ray_dir = normalize(canvas - eye);
    vec3 color = raymarch(eye, ray_dir);
    fragColor = vec4(color, 1.0);
}
