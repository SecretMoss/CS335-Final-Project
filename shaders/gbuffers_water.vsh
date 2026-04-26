#version 330 compatibility

out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos; // Sent to the fragment shader

out vec2 lightmapCoord;
out vec3 normal;


uniform float frameTimeCounter;
uniform sampler2D noisetex;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

in vec3 mc_Entity;    
flat out int blockId; 


void main() {
blockId = int(mc_Entity.x + 0.5);

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;

    vec4 position = gl_Vertex;


    vec4 viewPos = gl_ModelViewMatrix * position;
    worldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;

    if (gl_Normal.y > 0.5 && blockId == 100) {
        
        vec2 waveCoord = worldPos.xz * 0.1; 
        float wave1 = texture(noisetex, waveCoord * 0.5 + (frameTimeCounter * 0.003)).r;
        float wave2 = texture(noisetex, waveCoord * 1.5 - (frameTimeCounter * 0.005)).r;
        float finalWaveHeight = (wave1 + wave2) / 2.0;

  
        position.y += finalWaveHeight * 0.25; 
    }

    gl_Position = gl_ModelViewProjectionMatrix * position;
    lightmapCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    normal = normalize(gl_NormalMatrix * gl_Normal);
}