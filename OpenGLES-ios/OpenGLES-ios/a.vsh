precision highp float;
attribute vec4 position;
attribute vec4 color;
attribute vec2 texcoord;

varying vec4 colorVarying;
varying vec2 tex_coord;

void main(void)
{
    gl_Position = position;
    tex_coord = texcoord;
    colorVarying = color;
}

