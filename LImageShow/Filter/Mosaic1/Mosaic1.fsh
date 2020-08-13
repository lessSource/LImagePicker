
precision highp float;
uniform sampler2D Texture;
const vec2 TestSize = vec2(400.0, 400.0);
const vec2 MosaicSize = vec2(8.0, 8.0);
varying vec2 TextureCoordsVarying;

void main (void) {
    
    vec2 intXY = vec2(TextureCoordsVarying.x * TestSize.x, TextureCoordsVarying.y * TestSize.y);
    
    vec2 XYMosaic = vec2(floor(intXY.x/MosaicSize.x) * MosaicSize.x, floor(intXY.y/MosaicSize.y) * MosaicSize.y);
    
    vec2 UVMosaic = vec2(XYMosaic.x/TestSize.x, XYMosaic.y/TestSize.y);
    
    
    if (TextureCoordsVarying.x >= 0.5 && TextureCoordsVarying.y >= 0.5) {
        vec4 mask = texture2D(Texture, UVMosaic);
        gl_FragColor = vec4(mask.rgb, 1.0);
    }else {
        vec4 mask = texture2D(Texture, TextureCoordsVarying);        
        gl_FragColor = vec4(mask.rgb, 1.0);
    }
    

}
