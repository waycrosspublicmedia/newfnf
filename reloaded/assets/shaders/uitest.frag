#pragma header

// keep same macro style you used
#define iChannel0 bitmap
#define texture texture2D
#define fragColor gl_FragColor
#define mainImage main

uniform float u_progress; // 0..1 (0 = empty, 1 = full)

void mainImage()
{
    vec4 tex = texture2D(bitmap, openfl_TextureCoordv);

    // fill from bottom->top:
    // show when uv.y >= (1.0 - u_progress)
    float allow = step(1.0 - clamp(u_progress, 0.0, 1.0), openfl_TextureCoordv.y);

    // multiply rgb+alpha so it actually clips
    fragColor = tex * allow;
}