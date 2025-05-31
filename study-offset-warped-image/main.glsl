// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

// Strenght of offset
const float AMP = 1.;
// Propagation speed of waves
const float SPEED = .1;


const float PI = 3.14;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // [-1;1] coordinates and ratio fix
    vec2 uv = 2.*(.5-fragCoord.xy/iResolution.xy)*vec2(iResolution.x/iResolution.y,1.);

    float maxLength = iResolution.x/iResolution.y;
    float r = length(uv);
    float a = atan(uv.y, uv.x);
    a += pow((maxLength-r),AMP)*iTime*SPEED;
    uv = r * vec2(cos(a), sin(a));

    // Convert back to image coordinates in [0;1]
    uv = .5 - uv / (2.*vec2(iResolution.x/iResolution.y,1.));
    vec4 pic = texture(iChannel0,uv);


    // Output to screen
    fragColor = pic;
}
