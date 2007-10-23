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
#import <OpenGL/gl.h>

@interface GLView : NSOpenGLView
{
    int inited;
    
    void * userRefCon;
    
    BOOL opaque;
    
    NSTimer * ns_updateTimer;
    NSEvent * event;
    
    id delegate;
    
    unsigned long millisecondsCounter;
    unsigned long millisecondsPerFrame;
    
    UnsignedWide carryOver;
	UnsignedWide clock;
	
	long swap_enabled;
	
	BOOL shouldDrawFocusRing;
    NSResponder* lastResp;
}

- (void) setUserRefCon:(void *)data;
- (void *) userRefCon;

- (void) setDelegate:(id)d;
- (id) delegate;

- (NSEvent*) getEvent;

- (BOOL) acceptsFirstResponder;
- (BOOL) becomesFirstResponder;
- (BOOL) canBecomeKeyView;

- (void) resetUpdateTimer;

- (void) startUpdating;
- (void) stepUpdating;
- (void) stopUpdating;

@end
