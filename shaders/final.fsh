#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/*
const int colortex0Format = RGB16;
*/

void main() {
	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
	
}