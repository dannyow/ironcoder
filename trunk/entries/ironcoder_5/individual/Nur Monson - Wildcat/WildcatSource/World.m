//
//  World.m
//  Wildcat
//
//  Created by Nur Monson on 3/30/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "World.h"

#define NUMBER_OF_POINTS 64

@implementation World

- (id)init
{
	if( (self = [super init]) ) {
		_landSpline = SplineCreateHeight(NUMBER_OF_POINTS, 10.0f/(float)NUMBER_OF_POINTS);
		
		int pointIndex;
		for( pointIndex = 0; pointIndex < _landSpline->pointCount; pointIndex++ )
			_landSpline->heights[pointIndex] = SSRandomFloatBetween(0.1f,1.0f);
		// smooth them out with low-pass filter
		for( pointIndex = 0; pointIndex < _landSpline->pointCount; pointIndex++ ) {
			float sum = 0.0f;
			if( pointIndex == 0 )
				sum = _landSpline->heights[_landSpline->pointCount-1] + _landSpline->heights[_landSpline->pointCount-2];
			else if( pointIndex == 1 )
				sum = _landSpline->heights[_landSpline->pointCount-1] + _landSpline->heights[0];
			else
				sum = _landSpline->heights[pointIndex-2] + _landSpline->heights[pointIndex-1];
			
			_landSpline->heights[pointIndex] = (_landSpline->heights[pointIndex]+sum)/3.0f;
		}
		for( pointIndex = 0; pointIndex < _landSpline->pointCount; pointIndex++ )
			SplineCalculateSlopeAtPoint(_landSpline, pointIndex);
		
		_size = 10.0f;
		
		_creatures = [[NSMutableArray alloc] init];
		int i;
		for( i=0; i < 50; i++ ) {
			Creature *aCreature = [[Creature alloc] init];
			[aCreature randomize:_size];
			[_creatures addObject:aCreature];
		}
		_rockTexture = _grassTexture = _snowTexture = nil;
	}

	return self;
}

- (void)dealloc
{
	SplineHeightRelease(_landSpline);
	[_creatures release];
	[_creatureTexture release];
	[_rockTexture release];
	[_grassTexture release];
	[_snowTexture release];

	[super dealloc];
}

- (float)size
{
	return _size;
}

- (void)drawLandscapeFromStart:(unsigned int)startIndex toEnd:(unsigned int)endIndex withBottom:(float)bottomHeight stepSize:(float)stepSize
{
	endIndex++;
	if( endIndex >= _landSpline->pointCount )
		endIndex -= _landSpline->pointCount;
	
	glBegin(GL_TRIANGLE_STRIP); {
		unsigned int pointIndex = startIndex;
		float horizontalOffset = 0.0f;
		while( pointIndex != endIndex ) {
			
			float t;
			Vector2D drawPoint;
			for( t=0.0f; t < 1.0f; t += stepSize ) {
				drawPoint = SplineGetIntermediatePoint(_landSpline, pointIndex, t);
				drawPoint.x += horizontalOffset;
				//glColor4f(drawPoint.y,1.0f-drawPoint.y,0.3f,1.0f);
				glTexCoord2f( t*_landSpline->deltaH, 0.0f); glVertex2f(drawPoint.x,bottomHeight);
				glTexCoord2f( t*_landSpline->deltaH, drawPoint.y); glVertex2f(drawPoint.x ,drawPoint.y);
			}
			
			horizontalOffset += _landSpline->deltaH;
			pointIndex++;
			if( pointIndex == _landSpline->pointCount )
				pointIndex = 0;
		}
		
	} glEnd();
	
}

char *normalVS =
"varying vec4 diffuse,ambientGlobal,ambient;\n"
"varying vec3 normal,lightDir,halfVector;\n"
"varying float dist;\n"
"void main() {\n"
"	vec4 ecPos;\n"
"	vec3 aux;\n"
"	normal = normalize(gl_NormalMatrix * gl_Normal);\n"
"	ecPos = gl_ModelViewMatrix * gl_Vertex;\n"
"	aux = vec3(gl_LightSource[0].position-ecPos);\n"
"	lightDir = normalize(aux);\n"
"	dist = length(aux);\n"
"	halfVector = normalize(gl_LightSource[0].halfVector.xyz);\n"
"	diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;\n"
"	ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;\n"
"	ambientGlobal = gl_LightModel.ambient * gl_FrontMaterial.ambient;\n"
"	gl_Position = ftransform();\n"
"}";

void printShaderInfoLog(GLuint obj)
{
	GLint infologLength = 0;
	GLint charsWritten  = 0;
	char *infoLog;
	
	GLint result;
	glGetShaderiv(obj,GL_COMPILE_STATUS,&result);
	if( result != GL_FALSE )
		return;
	
	glGetShaderiv(obj, GL_INFO_LOG_LENGTH,&infologLength);
	
	if (infologLength > 0)
	{
		infoLog = (char *)malloc(infologLength);
		glGetShaderInfoLog(obj, infologLength, &charsWritten, infoLog);
		printf("%s\n",infoLog);
		free(infoLog);
	}
}

- (void)drawRangeStart:(float)rangeStart width:(float)rangeWidth
{
#ifdef USESHADERS
	if( _rockTexture == nil ) {
		_rockTexture = [[TIPTexture alloc] initWithPNG:[[NSBundle bundleForClass:[self class]] pathForResource:@"_rock" ofType:@"png"]];
		_grassTexture = [[TIPTexture alloc] initWithPNG:[[NSBundle bundleForClass:[self class]] pathForResource:@"_grass" ofType:@"png"]];
		_snowTexture = [[TIPTexture alloc] initWithPNG:[[NSBundle bundleForClass:[self class]] pathForResource:@"_snow" ofType:@"png"]];
		
		NSString *fragmentShaderString = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"landscape" ofType:@"frag"]];
		
		_fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
		const char *shaderCString = [fragmentShaderString cStringUsingEncoding:NSASCIIStringEncoding];
		glShaderSource(_fragmentShader,1,(const GLchar**)&shaderCString,NULL);
		glCompileShader(_fragmentShader);
		printShaderInfoLog(_fragmentShader);
		
		_vertexShader = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(_vertexShader,1,(const GLchar**)&normalVS,NULL);
		glCompileShader(_vertexShader);
		printShaderInfoLog(_vertexShader);
		
		_mainProgram = glCreateProgram();
		glAttachShader(_mainProgram,_vertexShader);
		glAttachShader(_mainProgram,_fragmentShader);
		glLinkProgram(_mainProgram);
	}
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, [_rockTexture textureID]);
	//glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, [_grassTexture textureID]);
	//glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, [_snowTexture textureID]);
	//glEnable(GL_TEXTURE_2D);
	
	glUseProgram(_mainProgram);
#endif
	
	glPushMatrix();
	//glTranslatef(0.0f,0.5f,0.0f);
	glScalef(1.0f,1.0f,1.0f);

	unsigned int startIndex = (unsigned int)floorf(rangeStart/_landSpline->deltaH);
	unsigned int endIndex = (unsigned int)ceilf((rangeStart+rangeWidth)/_landSpline->deltaH);
	if( endIndex >= _landSpline->pointCount )
		endIndex -= _landSpline->pointCount;
	
	unsigned int backStartIndex = endIndex;
	unsigned int backEndIndex = startIndex;
	if( backStartIndex == 0 )
		backStartIndex = _landSpline->pointCount-1;
	else
		backStartIndex--;
	
	if( backEndIndex == _landSpline->pointCount-1 )
		backEndIndex = 0;
	else
		backEndIndex++;
	
	glBindTexture(GL_TEXTURE_2D, 0);
	// draw background
	glColor4f(0.4f,0.0f,0.0f,1.0f);
	glPushMatrix();
	float translateX = ((float)backStartIndex*_landSpline->deltaH) - (rangeStart+rangeWidth);
	if( backStartIndex < backEndIndex || backEndIndex == 0 )
		translateX += _size;
	glTranslatef(0.0f,0.45f,0.0f);
	
	glScalef(-rangeWidth/(_size-rangeWidth),rangeWidth/(_size-rangeWidth),1.0f);
	glTranslatef( translateX -(_size-rangeWidth), 0.0f, 0.0f );
	[self drawLandscapeFromStart:backStartIndex toEnd:backEndIndex withBottom:-4.0f stepSize:0.2f];
	glPopMatrix();
	
	// draw foreground
	glColor4f(0.3f,0.5f,0.0f, 1.0f);
	glPushMatrix();
	glTranslatef( (float)startIndex*_landSpline->deltaH-rangeStart, 0.0f, 0.0f );
	[self drawLandscapeFromStart:startIndex toEnd:endIndex withBottom:0.0f stepSize:0.2f];
	glPopMatrix();
	//glUseProgram(0);
	
	// creature drawing
	if( _creatureTexture == nil ) {
		_creatureTexture = [[TIPTexture alloc] initWithPNG:[[NSBundle bundleForClass:[self class]] pathForResource:@"creature" ofType:@"png"]];
		//[_creatures performSelector:@selector(setTexture:) withObject:_creatureTexture];
		[_creatures makeObjectsPerformSelector:@selector(setTexture:) withObject:_creatureTexture];
	}
	NSEnumerator *creatureEnumerator = [_creatures objectEnumerator];
	Creature *aCreature;
	while( (aCreature = [creatureEnumerator nextObject]) ) {
		
		if( rangeStart < [aCreature position] && rangeStart+rangeWidth > [aCreature position] ) {
			glPushMatrix();
			unsigned int anIndex = (unsigned int)([aCreature position]/_landSpline->deltaH);
			float t = ([aCreature position] - floorf([aCreature position]/_landSpline->deltaH)*_landSpline->deltaH)/_landSpline->deltaH;
			Vector2D translate = SplineGetIntermediatePoint(_landSpline, anIndex, t);
			translate.x = translate.x + (float)anIndex*_landSpline->deltaH - rangeStart;
			glTranslatef( translate.x, translate.y, 0.0f);
			Vector2D slope = SplineGetIntermediateSlope(_landSpline, anIndex, t);
			[aCreature drawWithSlope:slope];
			glPopMatrix();
		}
		
		[aCreature simulate];
	}
	glPopMatrix();
}

@end
