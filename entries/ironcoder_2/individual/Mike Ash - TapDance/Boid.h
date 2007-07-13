//
//  Boid.h
//  TapDance
//
//  Created by Michael Ash on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Boid : NSObject {
	NSWindow*	mParentWin;
	NSWindow*	mWin;
	NSPoint 	mPos;
	float		mVx;
	float		mVy;
}

- initWithWindow: (NSWindow *)window image: (NSImage *)image offset: (NSPoint)offset origin: (NSPoint)origin size: (NSSize)size;

- (NSWindow *)window;
- (void)step;
- (void)hide;

- (NSPoint)pos;
- (float)vx;
- (float)vy;

@end

@interface NSWindow (Boids)

+ (BOOL)hasBoids;
- (void)boidify;
- (void)deboidify;

@end