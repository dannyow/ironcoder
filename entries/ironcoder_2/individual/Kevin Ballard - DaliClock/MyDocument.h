//
//  MyDocument.h
//  DaliClock
//
//  Created by Kevin Ballard on 7/23/06.
//  Copyright Tildesoft 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class ClockControl;

@interface MyDocument : NSDocument {
	NSTimer *animationTimer;
	ClockControl *clockControl;
	
	NSDate *startDate;
	NSTimeInterval duration;
	float slump;
	BOOL deformationComplete;
}
- (void)updateTime:(NSTimer *)aTimer;
- (void)updateDeformation:(NSTimer *)aTimer;
@end
