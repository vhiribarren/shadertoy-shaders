// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

// Radius of the base circle drawn with a gradient tone
const float RADIUS = 0.01;
// Number of waves between coordinates [0;1]
const float FREQ = 1.;
// Strenght of offset
const float AMP = .01;
// Propagation speed of waves
const float SPEED = 1.;
// Reset animation every period
const float PERIOD = 4.;


const float PI = 3.14;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // [-1;1] coordinates and ratio fix
    vec2 uv = 2.*(.5-fragCoord.xy/iResolution.xy)*vec2(iResolution.x/iResolution.y,1.);
    float periodicTime = mod(iTime, PERIOD);

    float radius = length(uv  - normalize(uv)*periodicTime*SPEED);
    float offset = AMP*sin(2.*PI*FREQ*radius)/(0.01+pow(radius, 2.));

    uv = uv + offset*normalize(uv);

    // Convert back to image coordinates in [0;1]
    uv = .5 - uv / (2.*vec2(iResolution.x/iResolution.y,1.));
    vec4 pic = texture(iChannel0,uv);


    // Output to screen
    fragColor = pic;
}
