// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

// Radius of the base circle drawn with a gradient tone
const float RADIUS = 0.05;
// Number of waves between coordinates [0;1]
const float FREQ = 5.;
// Strenght of offset
const float AMP = 0.01;
// Propagation speed of waves
const float SPEED = 0.1;


const float PI = 3.14;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // [-1;1] coordinates and ratio fix
    vec2 uv = 2.*(.5-fragCoord.xy/iResolution.xy)*vec2(iResolution.x/iResolution.y,1.);
    
    float offset = AMP * cos(2.*PI * FREQ *(length(uv) - iTime*SPEED));
    
    vec3 signed_dist = vec3(length(uv + offset*normalize(uv)) - RADIUS);
    vec3 col = 1.0 - signed_dist;

    // Output to screen
    fragColor = vec4(col,1.0);
}
