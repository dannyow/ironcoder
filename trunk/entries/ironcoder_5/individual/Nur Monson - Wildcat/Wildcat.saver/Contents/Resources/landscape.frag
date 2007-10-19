uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;

void main()
{
	vec4 color1;
	vec4 color2;
	float blender;
	
	if( gl_TexCoord[0].t < 0.5 ) {
		color1 = texture2D(tex1,gl_TexCoord[0].st);
		color2 = texture2D(tex2,gl_TexCoord[0].st);
		blender = gl_TexCoord[0].t/0.5;
	} else {
		color1 = texture2D(tex2,gl_TexCoord[0].st);
		color2 = texture2D(tex3,gl_TexCoord[0].st);
		blender = (gl_TexCoord[0].t-0.5)/0.5;
	}
	
	gl_FragColor = mix(color1,color2, blender);
}

