//
//  IronDazzleView.m
//  IronDazzle
//
//  Created by Tom Harrington on 7/21/06.
//  Copyright 2006 Tom Harrington. All rights reserved.
//

#import "IronDazzleView.h"
#import "IronDazzleItem.h"

static const int maxConfettiCount = 100;

/*
 Mouse motion causes confetti to appear
 Confetti moves when the timer fires.
 */
@implementation IronDazzleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		confettiTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1
														  target:self
														selector:@selector(updateConfetti:)
														userInfo:nil
														 repeats:YES] retain];
		confettiItems = [[NSMutableArray alloc] initWithCapacity:maxConfettiCount];
		colorCycle = 0.0;
    }
    return self;
}

// Move current confetti items as appropriate
// Delete any that are out of view
- (void)updateConfetti:(NSTimer *)timer
{
	int confettiIndex = [confettiItems count] - 1;
	IronDazzleItem *currentItem;
	NSRect myFrame = [self frame];
	CGRect cgFrame;
	
	cgFrame.origin.x = myFrame.origin.x;
	cgFrame.origin.y = myFrame.origin.y;
	cgFrame.size.width = myFrame.size.width;
	cgFrame.size.height = myFrame.size.height;
	
	NSPanel *dazzlePanel = (NSPanel *)[self window];
	NSPoint myOriginInScreenCoordinates = [dazzlePanel convertBaseToScreen:myFrame.origin];
	//NSLog(@"updating confetti with panel origin at %@", NSStringFromPoint(myOriginInScreenCoordinates));

	while (confettiIndex > 0) {
		currentItem = [confettiItems objectAtIndex:confettiIndex];
		[currentItem moveWithCurrentScreenOrigin:myOriginInScreenCoordinates];
		CGRect itemRect = [currentItem rect];
		if (CGRectContainsRect(cgFrame, itemRect) == 0) {
			[confettiItems removeObjectAtIndex:confettiIndex];
		}
		
		confettiIndex--;
	}
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	NSGraphicsContext *nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)[nsctx graphicsPort];


	// draw the clock face
	float clockSize = 50.0;
	float lineWidth = 2.0;
	// draw the clock on a layer, so it can be reused by all the confetti items
	clockLayer = CGLayerCreateWithContext(context, CGSizeMake(clockSize, clockSize),NULL);
	CGContextRef layerContext = CGLayerGetContext(clockLayer);

	//CGContextSetRGBFillColor(layerContext, 0.0, 1.0, 0.0, 0.7);
	colorCycle += 0.1;
	if (colorCycle > M_PI)
		colorCycle = 0.0;
	/*	
	CGContextSetRGBFillColor(layerContext, sin(colorCycle), cos(colorCycle), sin(colorCycle*2), 0.7);
	CGContextBeginPath(layerContext);
	CGContextAddArc(layerContext, (clockSize/2.0), (clockSize/2.0), (clockSize/2.0 - lineWidth), 0.0, 2*M_PI, 0);
	CGContextDrawPath(layerContext, kCGPathFillStroke);
*/	
	// draw the star
	float starSize = 50.0;
	CGContextSetLineWidth(layerContext, 1.0);
	CGContextSetRGBFillColor(layerContext, 1.0, 1.0, 0.0, 1.0);
	CGContextSaveGState(layerContext);
	CGContextTranslateCTM(layerContext, starSize/2.0, starSize/2.0);
	CGContextRotateCTM(layerContext, colorCycle*2.0);
	CGContextMoveToPoint(layerContext, 0.0, -starSize/2.0);
	CGContextAddArc(layerContext, starSize/2.0,		-starSize/2.0,	starSize/2.0,	M_PI,		M_PI/2,		1);
	CGContextAddArc(layerContext, starSize/2.0,		starSize/2.0,	starSize/2.0,	1.5*M_PI,	M_PI,		1);
	CGContextAddArc(layerContext, -starSize/2.0,	starSize/2.0,	starSize/2.0,	0.0,		1.5*M_PI,	1);
	CGContextAddArc(layerContext, -starSize/2.0,	-starSize/2.0,	starSize/2.0,	M_PI/2,		0.0,		1);
	CGContextDrawPath(layerContext, kCGPathFillStroke);
	CGContextRestoreGState(layerContext);
	
/*
	// this was supposed to be cool but ended up sucking
	CGContextSaveGState(layerContext);
	CGRect ourRect = {{0.0, 0.0}, {clockSize/2.0, clockSize/4.0}};
	int i, numRects=12;
	float rotateAngle = 2*M_PI/numRects;
	float tint, tintAdjust = 1.0/numRects;
	
	CGContextTranslateCTM(layerContext, (clockSize/2.0), (clockSize/2.0));
		
	for (i=0, tint=1.0; i<numRects; i++, tint-=tintAdjust) {
		CGContextSetRGBFillColor(layerContext, sin(rotateAngle*i), cos(rotateAngle*i), 0.5, 0.5);
		CGContextFillRect(layerContext, ourRect);
		CGContextRotateCTM(layerContext, rotateAngle);
	}
	CGContextRestoreGState(layerContext);
*/	
	CGContextSetLineWidth(layerContext, lineWidth);
	// Angle calculations adapted from Apple's "World Clock" widget.  Thanks, Apple!
	NSCalendarDate *now = [NSCalendarDate date];
	float minutesAngle = -[now minuteOfHour] * 0.10471975511965977;
	float hoursAngle = -(([now hourOfDay] % 12) * 0.523598775598) + (minutesAngle/6.283185481853 * 0.523598775598);
	// Rotate, because the angles are calculated from 12:00
	hoursAngle += M_PI/2.0;
	minutesAngle += M_PI/2.0;
	CGContextSetRGBStrokeColor(layerContext, 0.0, 0.0, 0.0, 1.0);
	// Draw hour hand
	CGContextSaveGState(layerContext);
	CGContextTranslateCTM(layerContext, (clockSize/2.0), (clockSize/2.0));
	CGContextRotateCTM(layerContext,hoursAngle);
	CGContextBeginPath(layerContext);
	CGContextMoveToPoint(layerContext, 0.0, 0.0);
	CGContextAddLineToPoint(layerContext, 0.3*clockSize, 0.0);
	CGContextDrawPath(layerContext,kCGPathStroke);
	CGContextRestoreGState(layerContext);
	// Draw minute hand
	CGContextSaveGState(layerContext);
	CGContextTranslateCTM(layerContext, (clockSize/2.0), (clockSize/2.0));
	CGContextRotateCTM(layerContext,minutesAngle);
	CGContextBeginPath(layerContext);
	CGContextMoveToPoint(layerContext, 0.0, 0.0);
	CGContextAddLineToPoint(layerContext, clockSize*0.5, 0.0);
	CGContextDrawPath(layerContext,kCGPathStroke);
	CGContextRestoreGState(layerContext);
	


	NSEnumerator *confettiEnumerator = [confettiItems objectEnumerator];
	IronDazzleItem *currentItem;
	while (currentItem = [confettiEnumerator nextObject]) {
		//[currentItem drawInContext:nsctx];
		[currentItem drawLayer:clockLayer inContext:context];
	}
}

- (void)addConfettiItemWithVector:(CGPoint)vector
{
	CGPoint location;
	NSRect myFrame = [self frame];

	NSPanel *dazzlePanel = (NSPanel *)[self window];
	NSPoint myOriginInScreenCoordinates = [dazzlePanel convertBaseToScreen:myFrame.origin];
	
	location.x = (myFrame.size.width / 2) + ((random() % 2) ? 1.0 : -1.0);
	location.y = (myFrame.size.height / 2) + ((random() % 2) ? 1.0 : -1.0);
	NSLog(@"Adding confetti item at (%f, %f) with vector (%f, %f)", location.x, location.y, vector.x, vector.y);
	
	IronDazzleItem *newItem = [[[IronDazzleItem alloc] initWithLocation:location vector:vector originalScreenLocation:myOriginInScreenCoordinates] autorelease];
	[confettiItems addObject:newItem];
	
	while ([confettiItems count] > maxConfettiCount) {
		NSLog(@"removing from confetti items");
		[confettiItems removeObjectAtIndex:0];
	}
}

@end
