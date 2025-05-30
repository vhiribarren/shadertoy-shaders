// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

// Number of waves between coordinates [0;1]
const float FREQ = 5.;
// Strenght of offset
const float AMP = 0.1;
// Propagation speed of waves
const float SPEED = 0.1;


const float PI = 3.14;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // [-1;1] coordinates and ratio fix
    vec2 uv = 2.*(.5-fragCoord.xy/iResolution.xy)*vec2(iResolution.x/iResolution.y,1.);

    float offset = AMP * cos(2.*PI * FREQ *(length(uv) - iTime*SPEED));
    uv = uv + offset*normalize(uv);

    // Convert back to image coordinates in [0;1]
    uv = .5 - uv / (2.*vec2(iResolution.x/iResolution.y,1.));
    vec4 pic = texture(iChannel0,uv);

    // Output to screen
    fragColor = pic;
}
