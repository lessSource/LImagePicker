precision highp float;
uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

void main (void) {
    vec4 mask = texture2D(Texture, TextureCoordsVarying);
    
    float Gray = mask.r * 0.299 + mask.g * 0.587 + mask.b * 0.114;
    mask.r = Gray;
    mask.g = Gray;
    mask.b = Gray;
    
    gl_FragColor = vec4(mask.rgb, 1.0);
}
