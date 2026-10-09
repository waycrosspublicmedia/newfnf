#pragma header

uniform vec2 redOff;
uniform vec2 greenOff;
uniform vec2 blueOff;

void main()
{
    vec2 uv = gl_FragCoord.xy / openfl_TextureSize;
	vec4 col;
	col.r = texture2D(bitmap, uv + redOff).r;
	col.g = texture2D(bitmap, uv + greenOff).g;
	col.b = texture2D(bitmap, uv + blueOff).b;
	col.a = texture2D(bitmap, openfl_TextureCoordv).a;

	gl_FragColor = col;
}