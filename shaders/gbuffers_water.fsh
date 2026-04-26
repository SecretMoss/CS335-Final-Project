#version 330 compatibility

uniform sampler2D gtexture; 
uniform sampler2D noisetex;
uniform float frameTimeCounter;

in vec2 texcoord;
in vec4 glcolor;
in vec3 worldPos;
flat in int blockId;

in vec2 lightmapCoord;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 normalData;

void main() {
    color = texture(gtexture, texcoord) * glcolor;

    if (blockId == 100) {
        vec2 waveCoord = worldPos.xz * 0.1; 
        float wave1 = texture(noisetex, waveCoord * 0.5 + (frameTimeCounter * 0.01)).r;
        float wave2 = texture(noisetex, waveCoord * 1.5 - (frameTimeCounter * 0.015)).r;
        float finalWaveHeight = (wave1 + wave2) / 2.0;

        vec3 troughColor = vec3(0.05, 0.15, 0.3); 
        vec3 peakColor = vec3(0.2, 0.4, 0.6);     

        color.rgb = mix(troughColor, peakColor, finalWaveHeight);
        color.a = 0.85; 
    }

    if (color.a < 0.1) {
        discard;
    }
    lightmapData = vec4(lightmapCoord, 0.0, 1.0);
    normalData = vec4(normal * 0.5 + 0.5, 1.0);
}