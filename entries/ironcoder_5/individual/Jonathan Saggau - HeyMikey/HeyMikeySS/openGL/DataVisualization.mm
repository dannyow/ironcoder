/*
 *  DataVisualization.c
 *  OpenGL Data Visualization - Lesson 1
 *
 *  Created by Rocco Bowling on 5/9/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "DataVisualization.h"

#import <Cocoa/Cocoa.h>
#import <GLUT/glut.h>
#import <ScreenSaver/ScreenSaver.h>
#include "NSImageOpenGLAdditions.h"


extern int useAllScreens;
extern int playAllSounds;
extern int playInitialSound;
//extern bool soundIsPlaying;
extern float zoom;
//background color RGBA
extern float backgroundColArr[4];

#pragma mark animation and cam positions
int animatingDraw = 0;
float animation = 0.0;
static float frAnimation = 0.0;
static float window_size[2];
//static float camera_location[3] = {0};

//static GLuint frTexture;

#pragma mark Color
static const GLfloat greyishColor[] = {0.55, 0.55, 0.65};

#pragma mark models
enum
{
	kModel_Mikey = 0,
	kModel_Exclam,
	kModel_NumberOfModels
};

/* static NSString * model_names[kModel_NumberOfModels] =
{
	@"dude.obj",
	@"exclam.obj"
}; */

#pragma mark textures
static GLuint lifeLogoTexture = 0;
static GLuint frTexture = 0;
NSSize frTextureSize;
NSMutableArray *allTextures;

static const char * impostor_program = 0;

#pragma mark sounds
static BOOL mikeyPlayed = NO;
static NSSound *heymikey;
static NSSound *letsgetmikey;
static NSSound *raisinlife;
static NSSound *notgonnatryit;
static NSSound *hehateseverything;
static NSSound *delicios;
NSMutableArray *mikeySounds;

#define answers 1


static float rotation_anim = 0.0;

static GLuint particle_texture = -1;

static GLuint imposter_program_object;

void frontRowSeat()
{
	//hehe...
	if(!mikeyPlayed && playInitialSound)
	{
		NSLog(@"mikey Play %@", heymikey);
		[heymikey play];
		mikeyPlayed = YES;
	}
	
	// stole bits of this one from Rocco... again
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
    {
		glDisable(GL_DEPTH_TEST);
		NSRect screen_frame = [[NSScreen mainScreen] frame];
		float hw = screen_frame.size.width * 0.5, hh = screen_frame.size.height * 0.5;
		frAnimation += 0.01;
		if(frAnimation > 1.0)
		{
			frAnimation = 1.0;
		}
		
		glLoadIdentity();
		gluOrtho2D(0.0, screen_frame.size.width, 0.0, screen_frame.size.height);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		glEnable(GL_TEXTURE_2D);
		
		// Render the logo
		glTranslated(hw, screen_frame.size.height, 0.0);
		
		glScalef(1.0 - (frAnimation * 0.75),
				 1.0 - (frAnimation * 0.75),
				 1.0);
	glReportError();
		glTranslated(0.0, -hh, 0.0);
	glReportError();
			
		glColor4f(1.0, 1.0, 1.0, 1.0 - frAnimation);
		glReportError();
		glBindTexture(GL_TEXTURE_2D, frTexture);
		glReportError();
		glBegin(GL_QUADS);
		glTexCoord2d(0.0, 0.0);
		glVertex2f(-hw, -hh);
		glTexCoord2d(10.0, 0.0);
		glVertex2f(hw, -hh);
		glTexCoord2d(10.0, 10.0);
		glVertex2f(hw, hh);
		glTexCoord2d(0.0, 10.0);
		glVertex2f(-hw, hh);
		
		glColor4f(1.0, 1.0, 1.0, 0.0);

		// Render the reflection...
		glTexCoord2d(0.0, 10.0);
		glVertex2f(-hw, -hh-frTextureSize.height);
		glTexCoord2d(10.0, 10.0);
		glVertex2f(hw, -hh-frTextureSize.height);
		glColor4f(1.0, 1.0, 1.0, (1.0 - frAnimation) * 0.5);
		glTexCoord2d(10.0, 0.0);
		glVertex2f(hw, hh-screen_frame.size.height);
		glTexCoord2d(0.0, 0.0);
		glVertex2f(-hw, hh-screen_frame.size.height);
		glEnd();
		glDisable(GL_BLEND);
	glReportError();
}glPopMatrix();
glReportError();
}

void randomSounds()
{
	// wait a little while...
	if(300 <= animation)
	{
		//gets a random sound and decides whether to play
		int whenToPlay = SSRandomIntBetween(0, 300);
		int hitTest = (int)animation % 301;
		if(hitTest == whenToPlay)
		{
			
			int whichToPlay = SSRandomIntBetween(0, 5);
			NSSound *playMe = [mikeySounds objectAtIndex:whichToPlay];
			[playMe play];
			NSLog(@"Random Sound %@", playMe);
			//soundIsPlaying = YES;
		}
	}
}

void renderSpinner()
{

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	const int N = 80;
	int i;
	int x, y, z;
	float scale;
	
	glPushMatrix();
	{
		glLoadIdentity();
		gluPerspective(60.0, (float)window_size[0] / window_size[1], 0.1, 200.0);
		glTranslatef(0.0, 0.0, -80.0);
		glRotated(rotation_anim, 0.25, 0.25, 0.5);
		
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, particle_texture);
		
		glEnable(GL_VERTEX_PROGRAM_ARB);
		glBindProgramARB(GL_VERTEX_PROGRAM_ARB, imposter_program_object);
		
		// Multiplied by the vertex color to provide the final color...
		glProgramLocalParameter4fARB(GL_VERTEX_PROGRAM_ARB, 0, 1.0, 1.0, 1.0, 1.0);
		
		glColor3f(1.0, 1.0, 1.0);
		
		glBegin(GL_QUADS);
		
		srand(12345);
		
		for(i = 0; i < N; i++)
		{
			x = (rand() % 100) - 50;
			y = (rand() % 100) - 50;
			z = (rand() % 100) - 50;
			
			scale = ((float)(rand() % 400) / 100.0) + 0.25;
			
			glNormal3f(-scale, -2.0*scale, 0.0);
			glTexCoord2f(0.0, 0.0);
			glVertex3i(x, y, z);
			
			glNormal3f(scale, -2.0*scale, 0.0);
			glTexCoord2f(1.0, 0.0);
			glVertex3i(x, y, z);
			
			glNormal3f(scale, scale, 0.0);
			glTexCoord2f(1.0, 1.0);
			glVertex3i(x, y, z);
			
			glNormal3f(-scale, scale, 0.0);
			glTexCoord2f(0.0, 1.0);
			glVertex3i(x, y, z);
			
		}
		
		glEnd();
		
		glDisable(GL_VERTEX_PROGRAM_ARB);
		
		glDisable(GL_TEXTURE_2D);
	} glPopMatrix();
}

void gradientQuad(const GLfloat lowerLeft[2], const GLfloat upperRight[2],    \
                  const GLfloat lowerColor[4], const GLfloat upperColor[4])
{
    glBegin(GL_QUADS);
    {
        GLfloat point1[] = {lowerLeft[0], lowerLeft[1], lowerLeft[2]};
        GLfloat point2[] = {upperRight[0], lowerLeft[1], upperRight[2]}; //lowerRight
        GLfloat point3[] = {upperRight[0], upperRight[1], upperRight[2]};
        GLfloat point4[] = {lowerLeft[0], upperRight[1], lowerLeft[2]}; //upperLeft
        
        glColor4fv(lowerColor);
        glVertex3fv(point1);
        glVertex3fv(point2);
        
        glColor4fv(upperColor);
        glVertex3fv(point3);
        glVertex3fv(point4);
    } glEnd();
}

void renderBackground()
{
    glDisable(GL_DEPTH_TEST);
    //fprintf(stderr, " Background!! %i  ", clickNumber);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    {
        glLoadIdentity();
        gluOrtho2D(0.0, 1.0, 0.0, 1.0);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glDisable(GL_LIGHTING);
        glDisable(GL_DEPTH_TEST);
        
        GLfloat lowerLeft[3] = {0.0, 0.0, 0.0};
        GLfloat upperRight[3] = {1.0, 0.5, 0.0};
        
        GLfloat upperColor[4] = {greyishColor[0], greyishColor[1], greyishColor[2], 1.0};
        
        gradientQuad(lowerLeft, upperRight, upperColor, backgroundColArr);
        glMatrixMode(GL_PROJECTION);
    }glPopMatrix();
}

void renderScene()
{
		renderBackground();

	renderSpinner();
	
	frontRowSeat();
	if (playAllSounds)
		randomSounds();
}

#pragma mark -
#pragma mark Load Media

void loadTextures()
{	
	allTextures = [[NSMutableArray alloc] initWithCapacity:8];
glReportError();
	NSImage *imageForTex;
	NSBundle *glVizBundle = [NSBundle bundleWithIdentifier:MODULE_NAME];

	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"mikeyeats" ofType:@"jpg"]];
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"mikeysurprised" ofType:@"jpg"]];
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"poprocks1" ofType:@"jpg"]];
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"poprocks2" ofType:@"jpg"]];
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"lifebox1" ofType:@"gif"]];
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"lifebox2" ofType:@"gif"]];	
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"lifebox3" ofType:@"jpg"]];	
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
	//OS X on a certain brand of vid card, ahem, needs Power of two textures to tile.  grumble grumble.
	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"lifelogoPOT" ofType:@"jpg"]];
	frTexture = lifeLogoTexture = [imageForTex texture:GL_REPEAT];
	frTextureSize = [imageForTex size];
	[allTextures addObject:[NSNumber numberWithInt:[imageForTex texture:GL_CLAMP_TO_EDGE]]];
	[imageForTex release];
glReportError();
}

void loadSounds()
{
	NSLog(@"Loading SOunds");
    mikeySounds = [[NSMutableArray alloc] initWithCapacity:6];
	NSBundle *glVizBundle = [NSBundle bundleWithIdentifier:MODULE_NAME];
	heymikey = [[NSSound alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"heymikey" ofType:@"wav"] byReference:YES];
	[mikeySounds addObject:heymikey];
	
	letsgetmikey = [[NSSound alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"letsgetmikey" ofType:@"wav"] byReference:YES];
	[mikeySounds addObject:letsgetmikey];	
	
	raisinlife = [[NSSound alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"raisinlife" ofType:@"wav"] byReference:YES];
	[mikeySounds addObject:raisinlife];	
	
	notgonnatryit = [[NSSound alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"notgonnatryit" ofType:@"wav"] byReference:YES];
	[mikeySounds addObject:notgonnatryit];	
	
	hehateseverything = [[NSSound alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"hehateseverything" ofType:@"wav"] byReference:YES];
	[mikeySounds addObject:hehateseverything];	
	
	delicios = [[NSSound alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"delicios" ofType:@"wav"] byReference:YES];
	[mikeySounds addObject:delicios];	
}

void initGL()
{
	GLdouble bounds[4];
	
	glGetDoublev(GL_VIEWPORT, bounds);
	
	window_size[0] = bounds[2];
	window_size[1] = bounds[3];
	
	glClearColor(0.0, 0.0, 0.0, 1.0);
	
	glShadeModel(GL_SMOOTH);

	glEnable(GL_CULL_FACE);
	glDisable(GL_DEPTH_TEST);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	// Load our impostor's texture
	glReportError();
	NSImage *imageForTex;
	NSBundle *glVizBundle = [NSBundle bundleWithIdentifier:MODULE_NAME];

	imageForTex = [[NSImage alloc] initWithContentsOfFile:[glVizBundle pathForResource:@"lifelogoPOT" ofType:@"jpg"]];
	particle_texture = [imageForTex texture:GL_CLAMP_TO_EDGE];
	[imageForTex release];

	// Load our vertex program
	impostor_program = [[NSString stringWithContentsOfFile:[glVizBundle pathForResource:@"impostor_program" ofType:@"shdr"]] UTF8String];
	
	if(!impostor_program)
	{
		fprintf(stderr, "Unable to load vertex program\n");
		exit(1);
	}
	
	// Bind our vertex program
	glGenProgramsARB(1, &imposter_program_object);
	glBindProgramARB(GL_VERTEX_PROGRAM_ARB, imposter_program_object);
	glProgramStringARB(GL_VERTEX_PROGRAM_ARB, GL_PROGRAM_FORMAT_ASCII_ARB, strlen(impostor_program), impostor_program);
	loadSounds();
	loadTextures();
}


void renderGL()
{

	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glColor3f(1.0, 1.0, 1.0);
		
	glLoadIdentity();

	renderScene();
}

void postRenderGL()
{
	
}

int updateGL()
{	
	rotation_anim += 2.5;
	animation += 1.0;
	return 1;
}

void reshapeGL(int width, int height)
{
	glViewport(0, 0, width, height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60.0, (float)width / height, 0.1, 200.0);
	glMatrixMode(GL_MODELVIEW);
	
	window_size[0] = width;
	window_size[1] = height;
}

void destructGL()
{
	
}


