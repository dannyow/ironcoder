//
//  CFallingSandView.m
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CFallingSandView.h"

#import "CSandbox.h"
#import "Utilities.h"

@implementation CFallingSandView

- (id)initWithFrame:(NSRect)inFrame
{
if ((self = [super initWithFrame:inFrame]) != NULL)
	{
	currentParticle = ParticleType_Sand;
	penRadius = 2.0f;
	}
return(self);
}

- (void)dealloc
{
[self setSandbox:NULL];
[self setImage:NULL];
//
[super dealloc];
}

- (void)mouseDown:(NSEvent *)inEvent
{
SCell theCell = { .particle = { .type = currentParticle } };

[NSEvent startPeriodicEventsAfterDelay:0.0f withPeriod:1 / 60.0f];

NSPoint theLocation = [self convertPoint:[inEvent locationInWindow] fromView:NULL];
[[self sandbox] setCircleOf:theCell center:theLocation radius:penRadius];
while (YES)
	{
	// wait for the next event we are interested in
	NSEvent *theEvent = [NSApp nextEventMatchingMask:NSOtherMouseUpMask | NSOtherMouseDraggedMask | NSPeriodicMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES];
	if ([theEvent type] == NSLeftMouseUp)
		{
		break;
		}
	else if ([theEvent type] == NSLeftMouseDragged)
		{
		theLocation = [self convertPoint:[theEvent locationInWindow] fromView:NULL];
		[[self sandbox] setCircleOf:theCell center:theLocation radius:penRadius];
		[self setNeedsDisplay:YES];
		[self displayIfNeeded];
		}
	else
		{
		[[self sandbox] update];
		[self setNeedsDisplay:YES];
		[self displayIfNeeded];
		}
	}
	
[NSEvent stopPeriodicEvents];
}

- (void)drawRect:(NSRect)inRect
{
NSEraseRect(inRect);

if ([self image] != NULL)
	{
	CGContextRef theGraphicsContext = [[NSGraphicsContext currentContext] graphicsPort];

	const NSSize theSize = [self bounds].size;
	CGRect theRect = { .origin = { .x = 0.0f, .y = 0.0f }, .size = { .width = theSize.width, .height = theSize.height } };

	CGImageRef theImage = [self image];
	CGContextDrawImage(theGraphicsContext, theRect, theImage);
	}
}

#pragma mark -

- (CSandbox *)sandbox
{
return(sandbox);
}

- (void)setSandbox:(CSandbox *)inSandbox
{
if (sandbox != inSandbox)
	{
	[sandbox autorelease];
	sandbox = [inSandbox retain];
	}
}

- (CGImageRef)image
{
return(image);
}

- (void)setImage:(CGImageRef)inImage
{
if (image != inImage)
	{
	if (image != NULL)
		{
		CFRelease(image);
		image = NULL;
		}
		
	if (inImage != NULL)
		{
		CFRetain(inImage);
		image = inImage;
		}
	[self setNeedsDisplay:YES];
	}
}

#pragma mark -

- (int)currentParticle
{
return(currentParticle);
}

- (void)setCurrentParticle:(int)inCurrentParticle
{
currentParticle = inCurrentParticle;
}

- (float)penRadius;
{
return(penRadius);
}

- (void)setPenRadius:(float)inPenRadius
{
penRadius = inPenRadius;
}

@end
