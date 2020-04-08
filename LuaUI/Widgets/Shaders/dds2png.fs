uniform sampler2D colors;


void main(void) {
	vec2 C0 = gl_TexCoord[0].st;
	vec4 orig = texture2D(colors, C0);

	gl_FragColor = vec4(orig.xyz, 1.0);
}
