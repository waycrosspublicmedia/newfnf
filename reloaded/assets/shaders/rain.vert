#pragma header

varying vec2 screenCoord;

void main() {

    #pragma body
    
    screenCoord = vec2(
        openfl_TextureCoord.x > 0.0 ? 1.0 : 0.0,
        openfl_TextureCoord.y > 0.0 ? 1.0 : 0.0
    );
}