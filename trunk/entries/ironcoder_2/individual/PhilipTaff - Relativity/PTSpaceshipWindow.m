//
//  PTSpaceshipWindow.m
//  Relativity
//
//  Created by Philip on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PTSpaceshipWindow.h"
#import "PTSpaceshipView.h"
#import <math.h>



@implementation PTSpaceshipWindow

- (void)awakeFromNib
{
	[self setContentView:[[PTSpaceshipView alloc] initWithFrame:[self frame]]];

	[self setSpeed:0];
	[self setSpeedOfLight:C];
}

#pragma mark NSWindow methods

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	NSRect windowFrame = NSMakeRect(contentRect.origin.x, contentRect.origin.y, 2*SHIP_SIZE, 2*SHIP_SIZE);

	self = [super initWithContentRect:windowFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self == nil)
		return nil;
		
	frameTimer = [[NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(update:) userInfo:NULL repeats:YES] retain];

	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	
	[self setContentView:[[PTSpaceshipView alloc] initWithFrame:[self frame]]];

	[self setSpeed:0];
	[self setSpeedOfLight:C];
	isDragging = NO;
	
	return self;
}

#pragma mark NSResponder methods

- (void)mouseDown:(NSEvent *)theEvent
{
	initialMouseLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	isDragging = YES;
	
	NSPoint newOrigin;
	newOrigin.x = initialMouseLocation.x-SHIP_SIZE;
	newOrigin.y = initialMouseLocation.y-SHIP_SIZE;
	
	[self setSpeed:0];
	lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
	
	//center window on click location and shift content
	[[self contentView] setOffset:NSMakePoint([self frame].origin.x-newOrigin.x, [self frame].origin.y-newOrigin.y)];
	[self setFrameOrigin:newOrigin];
	
	initialMouseLocation.x = initialMouseLocation.x - [self frame].origin.x;
	initialMouseLocation.y = initialMouseLocation.y - [self frame].origin.y;
	
	[[self contentView] setNextMouseLocation:[self frame].origin];
	[[self contentView] setNextMouseLocation:[self frame].origin];
	[[self contentView] updateTailVector];
	[[self contentView] setNeedsDisplay:YES];

}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint currentMouseLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	
	[self dragWindowTowardsPoint:currentMouseLocation];
}

- (void)mouseUp:(NSEvent *)theEvent 
{
	[self setSpeed:0];
	lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
	isDragging = NO;

	[[self contentView] setNextMouseLocation:[self frame].origin];
	[[self contentView] setNextMouseLocation:[self frame].origin];
	[[self contentView] updateTailVector];	
	[[self contentView] setNeedsDisplay:YES];
}

#pragma mark accessors

- (double)speed
{
	return speed;
}

- (void)setSpeed:(double)newSpeed
{
	speed = newSpeed;
	
	if ([[self contentView] respondsToSelector:@selector(setSpeed:)])
		[[self contentView] setSpeed:speed];
}

- (double)speedOfLight
{
	return speedOfLight;
}

- (void)setSpeedOfLight:(double)newSpeedOfLight
{
	speedOfLight = newSpeedOfLight;
	
	if ([[self contentView] respondsToSelector:@selector(setSpeedOfLight:)])
		[[self contentView] setSpeedOfLight:speedOfLight];
}

#pragma mark API

- (void)dragWindowTowardsPoint:(NSPoint)mouseLocation
{
	//prepare to move the window
	NSPoint newWindowOrigin;
	newWindowOrigin.x = mouseLocation.x - initialMouseLocation.x;
	newWindowOrigin.y = mouseLocation.y - initialMouseLocation.y;
	double dX = newWindowOrigin.x - [self frame].origin.x;
	double dY = newWindowOrigin.y - [self frame].origin.y;
	if ((dX == 0) & (dY == 0))
		return;
	
	//calculate speed for this move, and limit movement to <c
	double dT = [NSDate timeIntervalSinceReferenceDate] - lastUpdateTime;
	double newSpeed = sqrt(pow(dX,2)+pow(dY,2))/dT;
	if (newSpeed > speedOfLight)	{
		newWindowOrigin.x = dX*speedOfLight/newSpeed + [self frame].origin.x;
		newWindowOrigin.y = dY*speedOfLight/newSpeed + [self frame].origin.y;
		[self setSpeed:speedOfLight];
	}
	else	{
		[self setSpeed:newSpeed];
	}
	lastUpdateTime = lastUpdateTime + dT;
//	NSLog(@"new speed = %f", newSpeed);
	
	[self setFrameOrigin:newWindowOrigin];
	
	[[self contentView] setNextMouseLocation:[self frame].origin];
	[[self contentView] updateTailVector];	
	[[self contentView] setNeedsDisplay:YES];
}

- (void)update:(NSTimer *)myTimer
{
	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
	if (currentTime - lastUpdateTime > STOPPED_INTERVAL)	{
		[self setSpeed:0];
		lastUpdateTime = currentTime;
	}
	
	if (isDragging)
		[self dragWindowTowardsPoint:[NSEvent mouseLocation]];

	[[self contentView] setNeedsDisplay:YES];
}

@end
