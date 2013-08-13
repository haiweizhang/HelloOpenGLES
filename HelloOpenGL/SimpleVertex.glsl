attribute vec4 Position; // 1
attribute vec4 SourceColor; // 2
 
uniform mat4 Projection;
varying vec4 DestinationColor; // 3
uniform mat4 Modelview;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;
 
void main(void) { // 4
    DestinationColor = SourceColor; // 5
    //gl_Position = Position; // 6
    gl_Position = Projection * Modelview * Position;
    TexCoordOut = TexCoordIn;
}