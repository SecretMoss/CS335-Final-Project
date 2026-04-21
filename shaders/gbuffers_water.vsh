#version 330 compatibility

out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos; // Sent to the fragment shader


uniform float frameTimeCounter;
uniform sampler2D noisetex;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

in vec3 mc_Entity;    
flat out int blockId; 


void main() {
// We add 0.5 to prevent floating point rounding errors
blockId = int(mc_Entity.x + 0.5);

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;

    vec4 position = gl_Vertex;


    vec4 viewPos = gl_ModelViewMatrix * position;
    worldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;

    if (gl_Normal.y > 0.5 && blockId == 100) {
        
        vec2 waveCoord = worldPos.xz * 0.1; 
        float wave1 = texture(noisetex, waveCoord * 0.5 + (frameTimeCounter * 0.01)).r;
        float wave2 = texture(noisetex, waveCoord * 1.5 - (frameTimeCounter * 0.015)).r;
        float finalWaveHeight = (wave1 + wave2) / 2.0;

  
        position.y += finalWaveHeight * 0.05; 
    }

    // 6. Finalize the position using the newly displaced geometry
    gl_Position = gl_ModelViewProjectionMatrix * position;
}