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

#import <Cocoa/Cocoa.h>

@class GLView;

@interface GLVizController : NSObject
{
    GLView *openGLView;
	float zoom;
	NSColor *backgroundColor;
	
    BOOL _awoken;
    float _fps;
}

- (void)awake;

- (id)initWithOpenGLView:(GLView*)anOpenGLView zoom:(float)aZoom;
- (GLView *)openGLView;
- (void)setOpenGLView:(GLView *)anOpenGLView;
- (float)zoom;
- (void)setZoom:(float)aZoom;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aBackgroundColor;

@end
