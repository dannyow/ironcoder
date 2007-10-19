//
//  CrepuscularLife_View.m
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright (c) 2007, Twilight Edge Software. All rights reserved.
//

#import "CrepuscularLife_View.h"

#import "CrepuscularLife_GLView.h"
#import "CrepuscularLife_Generator.h"
#import "CrepuscularLife_OptionsController.h"
#import "CrepuscularLife_UserPrefs.h"

#define STABLE_CELL_COLOR_RED			0.8
#define STABLE_CELL_COLOR_GREEN			0.8
#define STABLE_CELL_COLOR_BLUE			0.8

#define NEW_CELL_COLOR_RED				0.9
#define NEW_CELL_COLOR_GREEN			0.9
#define NEW_CELL_COLOR_BLUE				0.1

#define BACK_GRADIENT_COLOR_RED			0.0
#define BACK_GRADIENT_COLOR_GREEN		0.0
#define BACK_GRADIENT_COLOR_BLUE		0.3

@interface CREPLIFE_View (PrivateMethods)

- (ScreenSaverDefaults *) loadPreferences;
- (void) setupOpenGL;
- (void) setFrameSize: (NSSize) newSize;

@end

@implementation CREPLIFE_View

- (id) initWithFrame: (NSRect) frame isPreview: (BOOL) isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];

    if (self) 
	{
		NSOpenGLPixelFormat *format;
		
		format = [CREPLIFE_GLView defaultPixelFormat];

		if (format == nil)
			goto ERROR;

		glView = [[CREPLIFE_GLView alloc] initWithFrame: NSZeroRect pixelFormat: format];
					
		if (glView == nil)
			goto ERROR;

		[self addSubview: glView];
		[self setupOpenGL];
		
		userPrefs = [[self loadPreferences] retain];
		
		if (userPrefs == nil)
			goto ERROR;
		
		srandom(time(0L));
	}

    return self;
	
ERROR:
	[self release];
	
	return nil;
}

- (void) dealloc
{
	if (currentGen)
		free(currentGen);
		
	if (nextGen)
		free(nextGen);
		
	if (newCellsVertexArray)
		free(newCellsVertexArray);
		
	if (stableCellsVertexArray)
		free(stableCellsVertexArray);

	[userPrefs release];
	[glView removeFromSuperview];
	[glView release];

	[super dealloc];
}

- (void) startAnimation
{
    [super startAnimation];
	
	[userPrefs synchronize];

	glidersPerGeneration = [userPrefs integerForKey: kCREPLIFEPrefsKeyGlidersPerGen];
	generationsPerGlider = [userPrefs integerForKey: kCREPLIFEPrefsKeyGensPerGlider];
	gliderFrequencyType = [userPrefs integerForKey: kCREPLIFEPrefsKeyGliderFreqType];
	
	generationSpeed = [userPrefs integerForKey: kCREPLIFEPrefsKeyGenSpeed];

	[self setAnimationTimeInterval: 1.0/((float) generationSpeed)];
	
	if ([self initializeFirstGeneration])
		animating = YES;
	else
		animating = NO;
}

- (void) stopAnimation
{
	animating = NO;
    [super stopAnimation];
}

- (void) drawRect: (NSRect) rect
{
    [super drawRect:rect];

	if (!animating)
		return;
	
	[[glView openGLContext] makeCurrentContext];
	
	glClear (GL_COLOR_BUFFER_BIT);
	
	glShadeModel(GL_SMOOTH);

	glBegin(GL_QUADS);
	{
		glColor3f(BACK_GRADIENT_COLOR_RED, BACK_GRADIENT_COLOR_GREEN, BACK_GRADIENT_COLOR_BLUE);
		glVertex2i(0,0);
		glVertex2i(lastCol,0);
		glColor3f(0,0,0);
		glVertex2i(lastCol, gradientHeight);
		glVertex2i(0, gradientHeight);
	}
	glEnd();
	
	glShadeModel(GL_FLAT);

	glColor3f(STABLE_CELL_COLOR_RED, STABLE_CELL_COLOR_GREEN, STABLE_CELL_COLOR_BLUE);

	glVertexPointer(2, GL_SHORT, 0, stableCellsVertexArray);
	glDrawArrays(GL_POINTS, 0, numStableCells);
	
	glColor3f(NEW_CELL_COLOR_RED, NEW_CELL_COLOR_GREEN, NEW_CELL_COLOR_BLUE);

	glVertexPointer(2, GL_SHORT, 0, newCellsVertexArray);
	glDrawArrays(GL_POINTS, 0, numNewCells);

	[[glView openGLContext] flushBuffer];
	
	[self nextGeneration];
}

- (void) animateOneFrame
{
	[self setNeedsDisplay: YES];
}

- (ScreenSaverDefaults *) loadPreferences
{
	ScreenSaverDefaults *preferences;
	NSDictionary *defaultPrefs = 
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: DEFAULT_GEN_SPEED], kCREPLIFEPrefsKeyGenSpeed,
			[NSNumber numberWithInt: DEFAULT_GLIDERS_PER_GEN], kCREPLIFEPrefsKeyGlidersPerGen,
			[NSNumber numberWithInt: DEFAULT_GENS_PER_GLIDER], kCREPLIFEPrefsKeyGensPerGlider,
			[NSNumber numberWithInt: DEFAULT_GLIDER_FREQ_TYPE], kCREPLIFEPrefsKeyGliderFreqType,
			nil];

	preferences = [ScreenSaverDefaults defaultsForModuleWithName: PREFS_DOMAIN];
	[preferences registerDefaults: defaultPrefs];

	return preferences;
}

- (void) setupOpenGL
{
    long swapInterval = 1;

	[[glView openGLContext] makeCurrentContext];
	
	glClearColor(0, 0, 0, 1.0);
	glShadeModel(GL_FLAT);

	[[glView openGLContext] setValues: &swapInterval 
		forParameter: NSOpenGLCPSwapInterval];
		
	glEnableClientState(GL_VERTEX_ARRAY);
}

- (void) setFrameSize: (NSSize) newSize
{
	numCols = newSize.width;
	numRows = newSize.height;
	
	lastRow = numRows-1;
	lastCol = numCols-1;
	
	gradientHeight = numRows/2;

	if (currentGen)
		free(currentGen);

	currentGen = (unsigned char *) malloc (numRows * numCols);
	
	if (nextGen)
		free(nextGen);
		
	nextGen = (unsigned char *) malloc (numRows * numCols);
	
	if (newCellsVertexArray)
		free(newCellsVertexArray);
		
	newCellsVertexArray = (GLshort *) malloc (sizeof(GLshort) * numRows * numCols);
	
	if (stableCellsVertexArray)
		free(stableCellsVertexArray);
		
	stableCellsVertexArray = (GLshort *) malloc (sizeof(GLshort) * numRows * numCols);
		
	[super setFrameSize: newSize];
	[glView setFrameSize: newSize];
	
	[[glView openGLContext] makeCurrentContext];
	
	glViewport(0,0,(GLsizei) newSize.width-1, (GLsizei) newSize.height-1);

	[[glView openGLContext] update];
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, newSize.width, 0, newSize.height, -200, 200);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glClear(GL_COLOR_BUFFER_BIT);
	[[glView openGLContext] flushBuffer];
}

- (BOOL) hasConfigureSheet
{
    return YES;
}

- (NSWindow*) configureSheet
{
	if (!optionsController)
	{
		optionsController = 
				[[CREPLIFE_OptionsController controllerWithUserPrefs: userPrefs] retain];
	}
	
	return [optionsController configureSheet];
}

@end
