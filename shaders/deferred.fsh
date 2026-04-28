#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D noisetex;

uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

#include "/settings.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec4 getNoise(vec2 coord){
  ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
  ivec2 noiseCoord = screenCoord % 64;
  return texelFetch(noisetex, noiseCoord, 0);
}

float computeSSAO(vec2 texcoord, float depth, vec3 normal) {
	if (depth == 1.0) return 1.0; // Sky, no occlusion

	vec3 NDCPos = vec3(texcoord, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	float radius = 0.5; // SSAO radius in view space
	int samples = 16;
	float occlusion = 0.0;

	vec4 noise = getNoise(texcoord);
	float theta = noise.r * 6.283185307; // 2*PI
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);
	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	for (int i = 0; i < samples; ++i) {
		float angle = (float(i) / float(samples)) * 6.283185307;
		vec2 offset = vec2(cos(angle), sin(angle)) * radius;
		offset = rotation * offset;

		vec2 sampleTexcoord = texcoord + offset / vec2(viewWidth, viewHeight);
		if (sampleTexcoord.x < 0.0 || sampleTexcoord.x > 1.0 || sampleTexcoord.y < 0.0 || sampleTexcoord.y > 1.0) continue;

		float sampleDepth = texture(depthtex0, sampleTexcoord).r;
		if (sampleDepth == 1.0) continue;

		vec3 sampleNDC = vec3(sampleTexcoord, sampleDepth) * 2.0 - 1.0;
		vec3 sampleViewPos = projectAndDivide(gbufferProjectionInverse, sampleNDC);

		float dist = distance(viewPos, sampleViewPos);
		if (dist > radius) continue;

		float occlusionFactor = max(0.0, dot(normal, normalize(sampleViewPos - viewPos)));
		occlusion += occlusionFactor * (1.0 - smoothstep(0.0, radius, dist));
	}

	occlusion /= float(samples);
	return 1.0 - clamp(occlusion * SSAO, 0.0, 1.0);
}

void main() {
	color = texture(colortex0, texcoord);

	if (SSAO > 0.0) {
		float depth = texture(depthtex0, texcoord).r;
		vec3 encodedNormal = texture(colortex2, texcoord).rgb;
		vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

		float ao = computeSSAO(texcoord, depth, normal);
		color.rgb *= ao;
	}
}
