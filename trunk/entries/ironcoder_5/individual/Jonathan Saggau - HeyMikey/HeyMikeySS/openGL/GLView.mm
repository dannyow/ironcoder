/**********************************************************************

Created by Rocco Bowling
Big Nerd Ranch, Inc
OpenGL Bootcamp

Copyright 2006-2007 Rocco Bowling and Jonathan Saggau, All rights reserved.

/***************************** License ********************************

This code can be freely used as long as these conditions are met:

1. This header, in its entirety, is kept with the code
3. It is not resold, in it's current form or in modified, as a
teaching utility or as part of a teaching utility

This code is presented as is. The author of the code takes no
responsibilities for any version of this code.

(c) 2006 Rocco Bowling and Jonathan Saggau

*********************************************************************/

#import "GLView.h"

#import <IOKit/IOKitLib.h>
#import <IOKit/graphics/IOFramebufferShared.h>

static NSOpenGLContext * gSharedOpenGLContext = 0;

@implementation GLView

- (void) windowWillClose:(NSNotification *)notification
{
	if([notification object] == [self window])
	{
		if(delegate && [delegate respondsToSelector:@selector(destructGL:)])
			[delegate performSelector:@selector(destructGL:) withObject:self];
		
		[delegate autorelease];
		delegate = 0;
				
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSWindowWillCloseNotification
													  object:[self window]];
	}
}

- (void) dealloc
{
    NSLog(@"GLVIEW dealloc");
	[delegate autorelease];
	delegate = 0;
	inited = 0;
    
	if([ns_updateTimer isValid] == YES)
	{
		[ns_updateTimer invalidate];
		
		[super dealloc];
		return;
	}
		
	[self clearGLContext];
	
	[ns_updateTimer release];
}

- (void)removeFromSuperview
{
	if([ns_updateTimer isValid] == YES)
	{
		[ns_updateTimer invalidate];
	}
	
	[delegate autorelease];
	delegate = 0;
	inited = 0;
	
	[super removeFromSuperview];
}

- (void) delayedInit
{
	if(!inited)
	{
        //NSLog(@"GLVIEW delayedInit");
        [[self openGLContext] makeCurrentContext];
        
        if(delegate && [delegate respondsToSelector:@selector(initGL:)])
			[delegate performSelector:@selector(initGL:) withObject:self];
        
		if(delegate && [delegate respondsToSelector:@selector(reshapeGL:)])
			[delegate performSelector:@selector(reshapeGL:) withObject:self];
		
        // Setup for transparency
        opaque = [[self window] isOpaque];
        
        if(opaque == NO)
        {
            long placement = -1;
            long opacity = 0;
            [[self openGLContext] setValues:&placement forParameter:NSOpenGLCPSurfaceOrder];
            [[self openGLContext] setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
            
            [[NSColor clearColor] set];
            NSRectFill([self bounds]);
        }
        
        millisecondsCounter = 0;
        millisecondsPerFrame = 20;
		
        memset(&carryOver, 0, sizeof(carryOver));
		
		Microseconds(&clock);
        
		swap_enabled = 1;
		[[self openGLContext] setValues:&swap_enabled forParameter:NSOpenGLCPSwapInterval];
		
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        
        inited = 1;
    }
}

- (id)initWithFrame:(NSRect)frameRect
		pixelFormat:(NSOpenGLPixelFormat*)format
{
    inited = 0;
    
    self = [super initWithFrame:frameRect pixelFormat:format];
	
	if(gSharedOpenGLContext)
	{
		NSOpenGLContext * myContext = [[[NSOpenGLContext alloc] initWithFormat:format shareContext:gSharedOpenGLContext] autorelease];
		[self setOpenGLContext:myContext];
		fprintf(stderr, "Using shared openGL context\n");
	}
	
	[self setFocusRingType:NSFocusRingTypeExterior];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowWillClose:)
												 name:NSWindowWillCloseNotification
											   object:[self window]];
			
	return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)32,
        (NSOpenGLPixelFormatAttribute)nil
    };
    
    NSOpenGLPixelFormat* pixFmt = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
    
    return [self initWithFrame:frameRect pixelFormat:pixFmt];
}

#pragma mark -

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (BOOL) becomesFirstResponder
{
    return YES;
}

- (BOOL)isOpaque
{
    return opaque;
}

- (void) setUserRefCon:(void *)data
{
    userRefCon = data;
}

- (void *) userRefCon
{
    return userRefCon;
}


- (void) setDelegate:(id)d
{
	[delegate autorelease];
    delegate = [d retain];
}

- (id) delegate
{
    return delegate;
}

#pragma mark -

- (BOOL)needsDisplay;
{
    NSResponder* resp = nil;
	
    if ( [[self window] isKeyWindow] ) 
    {
        resp = [[self window] firstResponder];
        if (resp == lastResp) 
            return [super needsDisplay];
    } 
    else if ( lastResp == nil )  
    {
        return [super needsDisplay];
    }
    shouldDrawFocusRing = (resp != nil && resp == self); 
    lastResp = resp;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    return YES;
}

- (void) drawRect: (NSRect) rect
{
	NSRect frame = [self frame];
	long swappingRect[4] =
	{
		(long)rect.origin.x,
		(long)rect.origin.y,
		(long)rect.size.width,
		(long)rect.size.height
	};
		
    [self delayedInit];
	
	if(rect.size.width == frame.size.width &&
	   rect.size.height == frame.size.height)
	{
		if(swap_enabled)
		{
			swap_enabled = 0;
			[[self openGLContext] setValues:&swap_enabled forParameter:NSOpenGLCPSwapRectangleEnable];
		}
	}
	else
	{
		if(!swap_enabled)
		{
			swap_enabled = 1;
			[[self openGLContext] setValues:&swap_enabled forParameter:NSOpenGLCPSwapRectangleEnable];
		}
		
		[[self openGLContext] setValues:swappingRect forParameter:NSOpenGLCPSwapRectangle];
	}
	
    if(delegate && [delegate respondsToSelector:@selector(renderGL:)])
		[delegate performSelector:@selector(renderGL:) withObject:self];
    
    [[self openGLContext] flushBuffer];
	glFlush();
	
	if(delegate && [delegate respondsToSelector:@selector(postRenderGL:)])
		[delegate performSelector:@selector(postRenderGL:) withObject:self];
}


- (unsigned long) getNumberOfUpdatesToPerform:(unsigned int) milliseconds
{
	unsigned long t;
	UnsignedWide nowTime, savedTime;
	
	Microseconds(&nowTime);
	savedTime = nowTime;    
	WideSubtract((wide *) &nowTime, (wide *) &clock);
	WideAdd((wide *) &carryOver, (wide *) &nowTime);
	clock = savedTime;
	
	
	milliseconds *= 1000;
	t = carryOver.lo / milliseconds;
	carryOver.lo %= milliseconds;
	
	return t;
}

- (void) updateTimer:(NSTimer *) localTimer
{
	if(inited)
    {
		int updated = 0;
		
		// Update Everything
		millisecondsCounter = [self getNumberOfUpdatesToPerform:millisecondsPerFrame];
		
		// If for some obscene reason its been over 10 seconds since the last time around...
		if(millisecondsCounter > (10000 / millisecondsPerFrame))
			millisecondsCounter = 0;
		
		while(millisecondsCounter--)
		{        
			if(delegate && [delegate respondsToSelector:@selector(updateGL:)])
				[delegate performSelector:@selector(updateGL:) withObject:self];
			updated = 1;
		}
	}
}

- (void) resetUpdateTimer
{
	millisecondsCounter = 0;
	Microseconds(&clock);
	memset(&carryOver, 0, sizeof(carryOver));
}

- (void) reshape
{
    if(inited)
    {
		[[self openGLContext] makeCurrentContext];
		
        if(delegate && [delegate respondsToSelector:@selector(reshapeGL:)])
			[delegate performSelector:@selector(reshapeGL:) withObject:self];
    }
}

- (NSEvent*) getEvent
{
    return event;
}

- (BOOL)canBecomeKeyView
{
	return YES;
}

#pragma mark -

- (void) startUpdating
// Start producing update calls
{
	if(!ns_updateTimer)
	{
		ns_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES] retain];
	}
}

- (void) stopUpdating
// Stop producing update calls
{
	if(ns_updateTimer)
	{
		if([ns_updateTimer isValid] == YES)
		{
			[ns_updateTimer invalidate];
		}
		[ns_updateTimer release];
        ns_updateTimer = NULL;
	}
}

- (void) stepUpdating
// Produce a single update call
{
	[self updateTimer:nil];
}

#pragma mark -

- (BOOL) hasFocus
{
	return ([NSView focusView] == self);
}

#pragma mark -

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if(inited)
	{
		if(delegate && [delegate respondsToSelector:@selector(eventGL:event:)])
		{
			[delegate performSelector:@selector(eventGL:event:) withObject:self withObject:theEvent];
		}
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if(inited)
	{
		if(delegate && [delegate respondsToSelector:@selector(eventGL:event:)])
		{
			[delegate performSelector:@selector(eventGL:event:) withObject:self withObject:theEvent];
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if(inited)
	{
		if(delegate && [delegate respondsToSelector:@selector(eventGL:event:)])
		{
			[delegate performSelector:@selector(eventGL:event:) withObject:self withObject:theEvent];
		}
	}
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	if(inited)
	{
		if(delegate && [delegate respondsToSelector:@selector(eventGL:event:)])
		{
			[delegate performSelector:@selector(eventGL:event:) withObject:self withObject:theEvent];
		}
	}
}


- (void)keyUp:(NSEvent *)theEvent
{
	if(inited)
	{
		if(delegate && [delegate respondsToSelector:@selector(eventGL:event:)])
		{
			[delegate performSelector:@selector(eventGL:event:) withObject:self withObject:theEvent];
		}
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if(inited)
	{
		if(delegate && [delegate respondsToSelector:@selector(eventGL:event:)])
		{
			[delegate performSelector:@selector(eventGL:event:) withObject:self withObject:theEvent];
		}
	}
}

#pragma mark -

- (void)draggedImage:(NSImage *)anImage
			 endedAt:(NSPoint)aPoint
		   operation:(NSDragOperation)operation
{
	if(delegate && [delegate respondsToSelector:@selector(draggedImage:endedAt:operation:)])
	{
		[delegate draggedImage:anImage
					   endedAt:aPoint
					 operation:operation];
	}
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	if(delegate && [delegate respondsToSelector:@selector(concludeDragOperation:)])
	{
		[delegate performSelector:@selector(concludeDragOperation:) withObject:sender];
	}
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if(delegate && [delegate respondsToSelector:@selector(draggingEntered:)])
	{
		return [delegate draggingEntered:sender];
	}
	
	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	if(delegate && [delegate respondsToSelector:@selector(draggingExited:)])
	{
		[delegate performSelector:@selector(draggingExited:) withObject:sender];
	}
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	if(delegate && [delegate respondsToSelector:@selector(draggingUpdated:)])
	{
		return [delegate draggingUpdated:sender];
	}
	
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	if(delegate && [delegate respondsToSelector:@selector(performDragOperation:)])
	{
		return [delegate performDragOperation:sender];
	}
	return NO;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	if(delegate && [delegate respondsToSelector:@selector(prepareForDragOperation:)])
	{
		return [delegate prepareForDragOperation:sender];
	}
	
	return NO;
}

- (BOOL)wantsPeriodicDraggingUpdates
{
	if(delegate && [delegate respondsToSelector:@selector(wantsPeriodicDraggingUpdates)])
	{
		return [delegate wantsPeriodicDraggingUpdates];
	}
	
	return NO;
}

@end
