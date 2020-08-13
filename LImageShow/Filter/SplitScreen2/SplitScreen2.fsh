precision highp float;
uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

void main (void) {
    
    vec2 uv = TextureCoordsVarying.xy;
    float y;
    float x;
    if (uv.y >= 0.0 && uv.y <= 0.5) {
        y = uv.y + 0.25;
    }else {
        y = uv.y - 0.25;
    }
    
    vec4 mask = texture2D(Texture, vec2(uv.x,y));
    gl_FragColor = vec4(mask.rgb, 1.0);
}
