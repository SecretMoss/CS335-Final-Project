#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float far;

uniform float alphaTestRef = 0.1;
uniform vec3 sunPosition;
uniform float frameTimeCounter;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in vec3 viewVector;
in vec3 worldPosition;

in float isWater; 

/* RENDERTARGETS: 0,1,2 */ 
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData; 
layout(location = 2) out vec4 normalData;   

float linearizeDepth(float depth) {
    float near = 0.05;
    float ndc = depth * 2.0 - 1.0; 
    return (2.0 * near * far) / (far + near - ndc * (far - near));
}

// Voronoi Math
vec2 hash2(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

float voronoi(vec2 p, float time) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float minDist = 1.0;
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = hash2(n + neighbor);
            point = 0.5 + 0.5 * sin(time + 6.2831 * point);
            vec2 diff = neighbor + point - f;
            float dist = length(diff); 
            if(dist < minDist) { minDist = dist; }
        }
    }
    return minDist;
}

void main() {
    color = texture(gtexture, texcoord) * glcolor;
    color *= texture(lightmap, lmcoord);

    if (isWater > 0.5) {
        // Lighting
        vec3 N = normalize(normal); 
        vec3 V = normalize(viewVector);
        vec3 L = normalize(sunPosition);
        vec3 H = normalize(L + V);

        // Voronoi
        float vSpeed = frameTimeCounter * 0.6;
        float vScale = 0.2; 
        
        float v = voronoi(worldPosition.xz * vScale, vSpeed);
        float webThickness = 2.0;
        float web = pow(v, webThickness); 

        float v2 = voronoi(worldPosition.xz * (vScale * 2.0), vSpeed * 1.5);
        float web2 = pow(v2, webThickness + 2.0) * 0.5;
        float totalWeb = clamp(web + web2, 0.0, 1.0);

        // Base color of the water
        vec3 base = vec3(0.02, 0.05, 0.08); 
        color.rgb = base * glcolor.rgb * texture(lightmap, lmcoord).rgb;
        color.a = 0.15;

        // Depth Fog
        vec2 screenPos = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
        float opaqueDepth = texture(depthtex0, screenPos).r;
        float surfaceDepth = gl_FragCoord.z;
        
        float depthDiff = linearizeDepth(opaqueDepth) - linearizeDepth(surfaceDepth);
        if (opaqueDepth > 0.9999) { depthDiff = 100.0; }
        
        float fogDensity = 0.15; 
        float depthFog = clamp(depthDiff * fogDensity, 0.0, 1.0);

        vec3 deepColor = vec3(0.0, 0.01, 0.02); 
        color.rgb = mix(color.rgb, deepColor, depthFog);

        // Fresnel
        float skyFactor = clamp(V.y, 0.0, 1.0);
        vec3 skyGradient = mix(vec3(0.3, 0.5, 0.7), vec3(0.1, 0.3, 0.8), skyFactor);
        float R0 = 0.02; 
        float fresnel = R0 + (1.0 - R0) * pow(1.0 - max(dot(N, V), 0.0), 5.0);
        color.rgb = mix(color.rgb, skyGradient, fresnel);

        // Voronoi Caustics
        vec3 webColor = vec3(0.7, 0.9, 1.0); 
        float webIntensity = 0.25; 
        color.rgb += totalWeb * webColor * webIntensity;

        // Specular Glint
        float specAngle = max(dot(N, H), 0.0);
        float specular = pow(specAngle, 256.0);
        vec3 specularColor = vec4(1.0, 0.95, 0.9, 1.0).rgb * 2.0; 
        color.rgb += specular * specularColor;
        
        color.a = clamp(color.a + fresnel + (depthFog * 0.9) + specular, 0.0, 1.0);
        normalData = vec4(N * 0.5 + 0.5, 1.0);
    } else {
        normalData = vec4(normalize(normal) * 0.5 + 0.5, 1.0);  
    }

    if (color.a < alphaTestRef) { discard; }

    lightmapData = vec4(lmcoord, 0.0, 1.0);
}