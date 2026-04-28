#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D normals;

uniform float alphaTestRef = 0.1;
uniform vec3 sunPosition;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in vec3 viewVector;

/* RENDERTARGETS: 0,1,2 */ 
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData; // Lighting buffer
layout(location = 2) out vec4 normalData;   // Normal buffer

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);

    vec3 N = normalize(normal);
    vec3 V = normalize(viewVector);
    float R0 = 0.02; 

    float fresnel = R0 + (1.0 - R0) * pow(1.0 - max(dot(N, V), 0.0), 5.0);
    vec3 skyColor = vec3(0.5, 0.7, 1.0); 
    color.rgb = mix(color.rgb, skyColor, fresnel);


    vec3 L = normalize(sunPosition);
    vec3 H = normalize(L + V);

    float specAngle = max(dot(N, H), 0.0);
    float shininess = 128.0;
    float specular = pow(specAngle, shininess);
    
    vec3 specularColor = vec4(1.0, 0.95, 0.9, 1.0).rgb * 2.0; 
    
    color.rgb += specular * specularColor;

	if (color.a < alphaTestRef) {
		discard;
	}

    lightmapData = vec4(lmcoord, 0.0, 1.0);
    normalData = vec4(normalize(normal) * 0.5 + 0.5, 1.0);
}