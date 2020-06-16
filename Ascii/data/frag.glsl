#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

// Processing specific input
uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;

// Layer between Processing and Shadertoy uniforms
vec3 iResolution = vec3(resolution,0.0);
float iGlobalTime = time;
vec4 iMouse = vec4(mouse,0.0,0.0); // zw would normally be the click status

// Bitmap to ASCII (not really) fragment shader by movAX13h, September 2013
// This is the original shader that is now used in PixiJs, FL Studio and various other products.

// Here's a little tool for new characters: thrill-project.com/archiv/coding/bitmap/

// update 2018-12-14: values for characters are integer now (were float)
//                    since bit operations are available now, making use of them
//                    instead of int(mod(n/exp2(p.x + 5.0*p.y), 2.0))

//tile variables
uniform float symbol_scale;
uniform float color_bin;

//Comments of explanation are from movAX13h

float character(int n, vec2 p)
{
	float maxVal = 	4.0;
	float offset = 2.5;
	p = floor(p*vec2(maxVal, -maxVal) + offset); // stretches it to -4 to 4 (y is flipped) and shifts it by 2.5 diagonally so that letters are not cut on screen 
    if (clamp(p.x, 0.0, maxVal) == p.x)
	{
        if (clamp(p.y, 0.0, maxVal) == p.y)	
		{
			//Note that the characters are 5x5 excluding the space around them
			//The index (variable a) for the look-up uses round(), thus giving results from 0 to 4 which matches the character size of 5x5.
        	int a = int(round(p.x) + 5.0 * round(p.y));
			if (((n >> a) & 1) == 1) return 1.0;
		}	
    }
	return 0.0;
}

void mainImage( out vec4 fragColor, in vec4 texCoord )
{
	vec2 pix = texCoord.st * iResolution.xy;
	vec3 col = texture2D(texture, floor(pix/(color_bin * symbol_scale))*(color_bin * symbol_scale)/iResolution.xy).rgb;	//Color pixelation
	vec3 colGray = texture2D(texture, floor(pix/(8.0 * symbol_scale))*(8.0 * symbol_scale)/iResolution.xy).rgb;	//Symbol pixelation

	float gray = 0.3 * colGray.r + 0.59 * colGray.g + 0.11 * colGray.b;
	
	int n =  4096;                // .
	if (gray > 0.1) n = 18157905;    // X
	if (gray > 0.2) n = 65600;    // :
	if (gray > 0.3) n = 332772;   // *
	if (gray > 0.4) n = 15255086; // o 
	if (gray > 0.5) n = 23385164; // &
	if (gray > 0.6) n = 15252014; // 8
	if (gray > 0.7) n = 13199452; // @
	if (gray > 0.8) n = 11512810; // #
	
	vec2 p = mod(pix/(4.0 * symbol_scale), 2.0) - vec2(1.0); // p into the range -1 to 1
    
	if (iMouse.x > 0.5 * iResolution.x)	col = gray*vec3(character(n, p));
	else col = col*character(n, p);
	
	fragColor = vec4(col, 1.0);
}



void main() {
	mainImage(gl_FragColor, vertTexCoord);
}

