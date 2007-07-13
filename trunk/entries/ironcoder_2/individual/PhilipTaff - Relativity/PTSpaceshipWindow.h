//
//  PTSpaceshipWindow.h
//  Relativity
//
//  Created by Philip on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define TIMER_INTERVAL 0.01
#define STOPPED_INTERVAL 0.5
#define C 1000


@interface PTSpaceshipWindow : NSWindow 
{
	double speed;
	double speedOfLight;

	BOOL isDragging;
	NSTimer *frameTimer;
	NSTimeInterval lastUpdateTime;
	NSPoint initialMouseLocation;
	NSPoint lastMouseLocation;
}

- (double)speed;
- (void)setSpeed:(double)newSpeed;
- (double)speedOfLight;
- (void)setSpeedOfLight:(double)newSpeedOfLight;

- (void)dragWindowTowardsPoint:(NSPoint)mouseLocation;
- (void)update:(NSTimer *)myTimer;

@end
