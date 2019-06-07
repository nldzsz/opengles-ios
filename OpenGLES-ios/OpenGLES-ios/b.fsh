precision highp float;
uniform sampler2D s_texture0;
uniform sampler2D s_texture1;

varying vec4 colorVarying;
varying vec2 tex_coord;

void main(void) {
    // draw
//    gl_FragColor = colorVarying;
    
    // texture
    vec4 color_rgb = texture2D(s_texture0,tex_coord);
//    vec4 color_rgb = vec4(texture2D(s_texture0,tex_coord).r + texture2D(s_texture1,tex_coord).r,
//                          texture2D(s_texture0,tex_coord).g + texture2D(s_texture1,tex_coord).g,
//                          texture2D(s_texture0,tex_coord).b + texture2D(s_texture1,tex_coord).b,
//                          1.0);
    if (color_rgb.r == 0.0) {
        gl_FragColor = vec4(1.0,1.0,1.0,1.0);
    } else {
        gl_FragColor = vec4(color_rgb.rgb,1.0);
    }
}
