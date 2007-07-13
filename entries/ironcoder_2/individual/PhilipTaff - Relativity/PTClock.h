//
//  PTClock.h
//  Relativity
//
//  Created by Philip on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTClock : NSObject 
{
	BOOL displaysTenths;
	BOOL displaysSeconds;
	BOOL displaysMinutes;
	BOOL displaysHours;
	
	double speed;
	double speedOfLight;
	double lorentz;

	NSTimeInterval currentTime;	//relativistic
	NSTimeInterval lastUpdateTime;	//non-relativistic
	NSSize size;
	
	CGPathRef segment1;
	CGPathRef segment2;
	CGPathRef segment3;
	CGPathRef segment4;
	CGPathRef segment5;
	CGPathRef segment6;
	CGPathRef segment7;
}

- (BOOL)displaysTenths;
- (void)setDisplaysTenths:(BOOL)flag;
- (BOOL)displaysSeconds;
- (void)setDisplaysSeconds:(BOOL)flag;
- (BOOL)displaysMinutes;
- (void)setDisplaysMinutes:(BOOL)flag;
- (BOOL)displaysHours;
- (void)setDisplaysHours:(BOOL)flag;
- (double)speed;
- (void)setSpeed:(double)newSpeed;
- (double)speedOfLight;
- (void)setSpeedOfLight:(double)newSpeedOfLight;
- (NSTimeInterval)currentTime;

- (id)initDisplayingHours:(BOOL)displayHours minutes:(BOOL)displayMinutes seconds:(BOOL)displaySeconds tenths:(BOOL)displayTenths;
- (void)drawInContext:(CGContextRef)context inRect:(CGRect)clockRect;
- (void)drawDigit:(int)digit inContext:(CGContextRef)context;
- (NSSize)size;

@end
