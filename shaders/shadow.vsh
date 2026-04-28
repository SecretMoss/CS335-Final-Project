#version 330 compatibility

out vec2 texcoord;
out vec4 glcolor;

#include "/lib/distort.glsl" 
#include "/lib/waves.glsl"

uniform mat4 shadowModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

attribute vec4 mc_Entity;

void main() {

    vec4 my_vertex = gl_Vertex;

    vec4 viewing_space_vertex = gl_ModelViewMatrix * my_vertex;

    vec4 player_pos = shadowModelViewInverse * viewing_space_vertex;

    vec3 world_pos = player_pos.xyz + cameraPosition;
    
    if(mc_Entity.x == 100.0){
        float wave = getWaveHeight(world_pos, frameTimeCounter);
        my_vertex.y += wave;
    }

    gl_Position = gl_ModelViewProjectionMatrix * my_vertex;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
    gl_Position.xyz = distortShadowClipPos(gl_Position.xyz); 
}