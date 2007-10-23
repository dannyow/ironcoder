/**********************************************************************

Created by Rocco Bowling and Jonathan Saggau
Big Nerd Ranch, Inc
OpenGL Bootcamp

Copyright 2006 Rocco Bowling and Jonathan Saggau, All rights reserved.

/***************************** License ********************************

This code can be freely used as long as these conditions are met:

1. This header, in its entirety, is kept with the code
3. It is not resold, in it's current form or in modified, as a
teaching utility or as part of a teaching utility

This code is presented as is. The author of the code takes no
responsibilities for any version of this code.

(c) 2006 Rocco Bowling and Jonathan Saggau

*********************************************************************/

#import "GLVizController.h"
#include <math.h>
#include "DataVisualization.h"
#include "GLView.h"

#define INITIAL_ZOOM_FACTOR 1.0

extern BOOL animatingDraw;

//float mouse_location[2];
float zoom = INITIAL_ZOOM_FACTOR;
float backgroundColArr[4]; 

float getFrameRate()
{
    static UnsignedWide	startMicroSec, endMicroSec;
    static int _awoken = 0;
    float frame;
	
    if(!_awoken){
    	Microseconds(&startMicroSec);
    	_awoken = 1;
    	return 0.0;
    }
    
    Microseconds(&endMicroSec);
    WideSubtract((wide *) &endMicroSec, (wide *) &startMicroSec);
    Microseconds(&startMicroSec); // start timing the next frame
	
    frame = 1000000.0/(float)endMicroSec.lo;
    Microseconds(&startMicroSec);
    
    return frame;
}

@interface GLVizController (privateAPI)

- (void) initGL:(GLView *)view;
- (void) renderGL:(GLView *)view;
- (void) postRenderGL:(GLView *)view;
- (void) updateGL:(GLView *)view;
- (void) reshapeGL:(GLView *)view;
- (void) destructGL:(GLView *)view;
//- (void) eventGL:(GLView *)view;
@end

@implementation GLVizController

- (id)init

{
    assert(0);
}

- (id)initWithOpenGLView:(GLView*)anOpenGLView zoom:(float)aZoom 
{
    if (self = [super init]) {
		_awoken = NO;
		zoom = INITIAL_ZOOM_FACTOR;
        [self setOpenGLView:anOpenGLView];
        [self setZoom:aZoom];
		NSColor *bkgd = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0];
		[self setBackgroundColor:bkgd];
    }
    return self;
}


- (void)awake
{
    _awoken = YES;
    [openGLView stepUpdating];
    [openGLView setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
	[self awake];
}

- (void)dealloc
{
    _awoken = NO; //keeps the view from updating
    [self setOpenGLView:nil];
    [super dealloc];
}

- (void)animateDraw;
{
    [openGLView startUpdating]; 
    //start constant updating
    //animate();
}

#pragma mark -
#pragma mark accessors


//=========================================================== 
//  zoom 
//=========================================================== 
- (float)zoom
{
    return zoom; 
}
- (void)setZoom:(float)aZoom
{
    if (zoom != aZoom) {
        zoom = aZoom;
        [openGLView stepUpdating];
    }
}

//=========================================================== 
//  openGLView 
//=========================================================== 
- (GLView *)openGLView
{
    return openGLView; 
}
- (void)setOpenGLView:(GLView *)anOpenGLView
{
    if (openGLView != anOpenGLView) {
        [anOpenGLView retain];
        [openGLView release];
        openGLView = anOpenGLView;
    }
}

//=========================================================== 
//  backgroundColor 
//=========================================================== 
- (NSColor *)backgroundColor
{
    return backgroundColor; 
}
- (void)setBackgroundColor:(NSColor *)aBackgroundColor
{
    if (backgroundColor != aBackgroundColor) {
        [aBackgroundColor retain];
        [backgroundColor release];
        backgroundColor = aBackgroundColor;
        [backgroundColor getRed:&backgroundColArr[0]
                          green:&backgroundColArr[1] 
                           blue:&backgroundColArr[2] 
                          alpha:&backgroundColArr[3]]; 
        [openGLView stepUpdating];
    }
}

#pragma mark -
#pragma mark OpenGL

- (void) initGL:(GLView *)view
{
	initGL(); 
	//constant updates and anim
	[view startUpdating]; 
}

- (void) renderGL:(GLView *)view
{
	/* LogMethod();
	NSLog(@"VIEW = %@", view); */
    renderGL();
	_fps = getFrameRate();
}

- (void) postRenderGL:(GLView *)view
{ 
	/* LogMethod();
	NSLog(@"VIEW = %@", view); */

	postRenderGL();
}

- (void) updateGL:(GLView *)view
{
	/* LogMethod();
	NSLog(@"VIEW = %@", view); */
	
  	if(updateGL())
	{
		[view setNeedsDisplay:YES];
	}
	
    if (!animatingDraw)
    {
        //[openGLView stopUpdating];
        //If nothing is moving, we don't need to update anymore
    }
}

- (void) reshapeGL:(GLView *)view
{
	/* LogMethod();
	NSLog(@"VIEW = %@", view); */
    if (_awoken)
    {
        NSRect frame = [view frame];
        reshapeGL((int)frame.size.width, 
                  (int)frame.size.height);
        [view stepUpdating];
    }
}

- (void) destructGL:(GLView *)view
{
	NSLog(@"VIEW = %@", view);
	destructGL();
}

@end