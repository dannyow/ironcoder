//
//  PTSpaceshipView.h
//  Relativity
//
//  Created by Philip on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTClock.h"

#define SHIP_SIZE 250

@interface PTSpaceshipView : NSView 
{
	PTClock *clock;

	double speed;
	double speedOfLight;
	double lorentz;

	NSPoint offset;
	NSPoint newMouseLocation;
	NSPoint oldMouseLocation;
	
	double tailAngle;	//in radians
}

- (PTClock *)clock;
- (double)speed;
- (void)setSpeed:(double)newSpeed;
- (double)speedOfLight;
- (void)setSpeedOfLight:(double)newSpeedOfLight;
- (NSPoint)offset;
- (void)setOffset:(NSPoint)newOffset;
- (NSPoint)newMouseLocation;
- (NSPoint)oldMouseLocation;
- (void)setNextMouseLocation:(NSPoint)newLocation;
- (double)tailAngle;
- (void)updateTailVector;

@end
