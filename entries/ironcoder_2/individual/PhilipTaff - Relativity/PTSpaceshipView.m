//
//  PTSpaceshipView.m
//  Relativity
//
//  Created by Philip on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PTSpaceshipView.h"
#import <math.h>
#define PI 3.141592653589793238462643383279502884197169399375105820974944592
#define ANGLE_SMOOTHER 0.3
#import "relativity.h"


double inRangeAngle(double outOfRangeAngle)
{
	if (outOfRangeAngle > PI)
		return (outOfRangeAngle - 2*PI);
	else if (outOfRangeAngle <= -PI)
		return (outOfRangeAngle + 2*PI);
	
	return outOfRangeAngle;
}


#pragma mark -



@implementation PTSpaceshipView



#pragma mark NSView methods

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame]) == nil)
		return nil;
		
	offset = NSMakePoint(SHIP_SIZE, SHIP_SIZE);
	tailAngle = 0;
	
	clock = [[PTClock alloc] initDisplayingHours:NO minutes:NO seconds:YES tenths:YES];
	
	[self setSpeedOfLight:100];
	[self setSpeed:0];	
	
	return self;
}

- (void)drawRect:(NSRect)rect 
{
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(currentContext);
	
	CGContextTranslateCTM(currentContext, offset.x, offset.y);
	CGContextRotateCTM(currentContext, tailAngle);
	CGContextScaleCTM(currentContext, lorentz, 1);
	
	CGContextClipToRect(currentContext, CGRectMake(-180, -SHIP_SIZE, 2*180, 2*SHIP_SIZE));
	
	CGContextBeginPath(currentContext);
	CGContextAddArc(currentContext, 160, 0, 80, PI/2, 3*PI/2, 0);
	CGContextSetRGBFillColor(currentContext, 0, 0, 1, 1);
	CGContextFillPath(currentContext);
	
	CGContextSetRGBFillColor(currentContext, 1, 0, 0, 1);
	CGContextFillEllipseInRect(currentContext, CGRectMake(-50, -50, SHIP_SIZE, 100));	
	CGContextSetRGBFillColor(currentContext, 0, 0, 0, 1);
	CGContextFillEllipseInRect(currentContext, CGRectMake(-25, -25, 50, 50));

	//draw the clock
	NSSize clockSize = [clock size];
	CGRect clockRect = CGRectMake(50, -(clockSize.height), 2*clockSize.width, 2*clockSize.height);
	[clock drawInContext:currentContext inRect:clockRect];
	
	CGContextRestoreGState(currentContext);
	
	[[self window] invalidateShadow];
}

#pragma mark accessors

- (PTClock *)clock
{
	return clock;
}

- (double)speed
{
	return speed;
}

- (void)setSpeed:(double)newSpeed
{
	speed = newSpeed;
	
	if (speedOfLight == 0)	{
		NSLog(@"The speed of light is 0?  No way!");
		return;
	}
	lorentz = sqrt(1 - pow(speed, 2)/pow(speedOfLight, 2));

	if ([[self clock] respondsToSelector:@selector(setSpeed:)])
		[[self clock] setSpeed:speed];
}

- (double)speedOfLight
{
	return speedOfLight;
}

- (void)setSpeedOfLight:(double)newSpeedOfLight
{
	speedOfLight = newSpeedOfLight;
	
	if (speedOfLight == 0)	{
		NSLog(@"The speed of light is 0?  No way!");
		return;
	}
	lorentz = sqrt(1 - pow(speed, 2)/pow(speedOfLight, 2));

	if ([[self clock] respondsToSelector:@selector(setSpeedOfLight:)])
		[[self clock] setSpeedOfLight:speedOfLight];
}

- (NSPoint)offset
{
	return offset;
}

- (void)setOffset:(NSPoint)newOffset
{
	offset.x = offset.x + newOffset.x;
	offset.y = offset.y + newOffset.y;
}

- (NSPoint)newMouseLocation
{
	return newMouseLocation;
}

- (NSPoint)oldMouseLocation
{
	return oldMouseLocation;
}

- (void)setNextMouseLocation:(NSPoint)newLocation
{
	oldMouseLocation = newMouseLocation;
	newMouseLocation = newLocation;
}

- (double)tailAngle
{
	return tailAngle;
}

- (void)updateTailVector
{
	NSPoint directionVector;
	directionVector.x = oldMouseLocation.x - newMouseLocation.x;
	directionVector.y = oldMouseLocation.y - newMouseLocation.y;
	
	double deltaAngle = inRangeAngle(atan2(directionVector.y, directionVector.x) - tailAngle);
	//use deltaAngle to adjust tailAngle, smoothing abrupt changes
	if (deltaAngle > ANGLE_SMOOTHER)	{
		tailAngle = tailAngle + ANGLE_SMOOTHER;
	}
	else if (deltaAngle >= -ANGLE_SMOOTHER)	{
		tailAngle = deltaAngle + tailAngle;
	}
	else	{
		tailAngle = tailAngle - ANGLE_SMOOTHER;
	}
	tailAngle = inRangeAngle(tailAngle);
}

@end
