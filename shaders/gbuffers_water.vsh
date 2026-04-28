#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out float isWater;
out vec3 normal;

#include "/lib/waves.glsl"

attribute vec4 mc_Entity;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

void main() {

    vec4 my_vertex = gl_Vertex;
    vec4 viewing_space_vertex = gl_ModelViewMatrix * my_vertex;
    vec4 player_pos = gbufferModelViewInverse * viewing_space_vertex;
    vec3 world_pos = player_pos.xyz + cameraPosition;
    if(mc_Entity.x == 100.0){
        isWater = 1.0;

        float wave = getWaveHeight(world_pos, frameTimeCounter);

        my_vertex.y += wave;
    } else{
        isWater = 0.0;
    }
    

    gl_Position = gl_ModelViewProjectionMatrix * my_vertex;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

    normal = gl_NormalMatrix * gl_Normal;

}