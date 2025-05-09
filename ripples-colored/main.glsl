// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Author: Vincent Hiribarren

const float u_speed = 0.1;
const float u_frequence = 20.0;
const float u_amplitude = 0.1;
const float u_decrease = 10.0;

const float PI = 3.14;

vec3 hsl2rgb(float hue, float saturation, float lightness) {
  // From https://en.wikipedia.org/wiki/HSL_and_HSV
  float c = (1.0 - abs(2.0 * lightness - 1.0)) * saturation;
  float hp = hue * 6.0;
  float x = c * (1.0 - abs(mod(hp, 2.0) - 1.0));
  vec3 rgb1;
  if (hp < 1.0) {
    rgb1 = vec3(c, x, 0.0);
  } else if (hp < 2.0) {
    rgb1 = vec3(x, c, 0.0);
  } else if (hp < 3.0) {
    rgb1 = vec3(0.0, c, x);
  } else if (hp < 4.0) {
    rgb1 = vec3(0.0, x, c);
  } else if (hp < 5.0) {
    rgb1 = vec3(x, 0.0, c);
  } else {
    rgb1 = vec3(c, 0.0, x);
  }
  float m = lightness - c/2.0;
  return rgb1 + m;
}

mat2 rotate2d(float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = fragCoord / iResolution.xy;
  uv = 2.0*(uv - 0.5) * vec2(iResolution.x/iResolution.y, 1.0);
  
  float time = iTime * u_speed;
  float distance = length(uv);
  float ampl = u_amplitude;
  ampl *= 1.0 / (1.0 + pow(distance, u_decrease));
  uv.x += ampl * cos(u_frequence * (distance - time));
  uv.y += ampl * sin(u_frequence * (distance - time));

  uv = rotate2d(time) * uv;

  float angle = atan(uv.y, uv.x);       // [-PI, PI]
  float hue = angle / (2.0 * PI) + 0.5; // [0, 1]]
  float lightness = 0.5;                //(1.0-length(uv));
  vec3 color = hsl2rgb(hue, 1.0, lightness);

  fragColor = vec4(color, 1.0);
}
