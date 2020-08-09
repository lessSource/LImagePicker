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
    
//    vec2 uv = TextureCoordsVarying.xy;
//    if (uv.x < 1.0 / 3.0) {
//        uv.x = uv.x * 3.0;
//    } else if (uv.x < 2.0 / 3.0) {
//        uv.x = (uv.x - 1.0 / 3.0) * 3.0;
//    } else {
//        uv.x = (uv.x - 2.0 / 3.0) * 3.0;
//    }
//    if (uv.y <= 1.0 / 3.0) {
//        uv.y = uv.y * 3.0;
//    } else if (uv.y < 2.0 / 3.0) {
//        uv.y = (uv.y - 1.0 / 3.0) * 3.0;
//    } else {
//        uv.y = (uv.y - 2.0 / 3.0) * 3.0;
//    }
    
    vec4 mask = texture2D(Texture, vec2(uv.x,y));
//    vec4 mask = texture2D(Texture, uv);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
