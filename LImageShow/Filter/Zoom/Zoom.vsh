
attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;
uniform float Time;
const float PI = 3.1415926;

void main (void) {
    
    float duration = 0.6;
    float maxAmplitude = 0.3;
    
    float time = mod(Time, duration);
    
    float amolitude = 1.0 + maxAmplitude * abs(sin(time * (PI / duration)));
    
    
    gl_Position = vec4(Position.x * amolitude, Position.y * amolitude, Position.zw);
    TextureCoordsVarying = TextureCoords;
}

