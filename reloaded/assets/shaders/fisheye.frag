#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture texture2D
#define fragColor gl_FragColor
#define mainImage main 

uniform float strength;

void mainImage()
{
    vec2 uv = openfl_TextureCoordv.xy;

    uv -= 0.5;

    float x2 = uv.x * uv.x;
    float y2 = uv.y * uv.y;
    float len2 = x2 + y2;

    float factor = 1.0 - strength * len2;

    uv *= factor;
    uv += 0.5;

    vec4 color = texture2D(bitmap, uv);
    gl_FragColor = color;
}