//
//  PTClock.m
//  Relativity
//
//  Created by Philip on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PTClock.h"


@implementation PTClock

#pragma mark NSObject methods

- (id)init
{
	return [self initDisplayingHours:YES minutes:YES seconds:NO tenths:NO];
}

#pragma mark accessors

- (BOOL)displaysTenths
{
	return displaysTenths;
}

- (void)setDisplaysTenths:(BOOL)flag
{
	displaysTenths = flag;

	if (displaysTenths && displaysHours && !displaysMinutes)	
		[self setDisplaysMinutes:YES];
	if (displaysTenths && displaysMinutes && ! displaysSeconds)
		[self setDisplaysSeconds:YES];
}

- (BOOL)displaysSeconds
{
	return displaysSeconds;
}

- (void)setDisplaysSeconds:(BOOL)flag
{
	if ( (!flag) && displaysTenths && displaysMinutes )
		return;
	displaysSeconds = flag;
	
	if (displaysSeconds && displaysHours && !displaysMinutes)
		[self setDisplaysMinutes:YES];
}

- (BOOL)displaysMinutes
{
	return displaysMinutes;
}

- (void)setDisplaysMinutes:(BOOL)flag
{
	if ( (!flag) && displaysHours && displaysSeconds )
		return;
	displaysMinutes = flag;
	
	if (displaysMinutes && displaysTenths && !displaysSeconds)
		[self setDisplaysSeconds:YES];
}

- (BOOL)displaysHours
{
	return displaysHours;
}

- (void)setDisplaysHours:(BOOL)flag
{
	displaysHours = flag;

	if (displaysHours && displaysTenths && !displaysSeconds)	
		[self setDisplaysSeconds:YES];
	if (displaysHours && displaysSeconds && !displaysMinutes)
		[self setDisplaysMinutes:YES];
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
}

- (NSTimeInterval)currentTime
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	currentTime = (now - lastUpdateTime)*lorentz + currentTime;
	lastUpdateTime = now;
	
	return currentTime;
}

#pragma mark API

- (id)initDisplayingHours:(BOOL)displayHours minutes:(BOOL)displayMinutes seconds:(BOOL)displaySeconds tenths:(BOOL)displayTenths
{
	if ((self = [super init]) == nil)
		return nil;
	
	[self setDisplaysHours:displayHours];
	[self setDisplaysMinutes:displayMinutes];
	[self setDisplaysSeconds:displaySeconds];
	[self setDisplaysTenths:displayTenths];
	
	[self setSpeedOfLight:100];
	[self setSpeed:0];
	
	currentTime = [NSDate timeIntervalSinceReferenceDate];
	lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
	
	CGMutablePathRef path1 = CGPathCreateMutable();
	CGPoint pathPoints1[] = {{3,22}, {11,22}, {9,20}, {5,20}};
	CGPathAddLines(path1, NULL, pathPoints1, 4);
	CGPathCloseSubpath(path1);
	segment1 = CGPathCreateCopy(path1);
	CGPathRelease(path1);
		
	CGMutablePathRef path2 = CGPathCreateMutable();
	CGPoint pathPoints2[] = {{12,21}, {12,13}, {10,15}, {10,19}};
	CGPathAddLines(path2, NULL, pathPoints2, 4);
	CGPathCloseSubpath(path2);
	segment2 = CGPathCreateCopy(path2);
	CGPathRelease(path2);
		
	CGMutablePathRef path3 = CGPathCreateMutable();
	CGPoint pathPoints3[] = {{12,11}, {12,3}, {10,5}, {10,9}};
	CGPathAddLines(path3, NULL, pathPoints3, 4);
	CGPathCloseSubpath(path3);
	segment3 = CGPathCreateCopy(path3);
	CGPathRelease(path3);
		
	CGMutablePathRef path4 = CGPathCreateMutable();
	CGPoint pathPoints4[] = {{3,2}, {11,2}, {9,4}, {5,4}};
	CGPathAddLines(path4, NULL, pathPoints4, 4);
	CGPathCloseSubpath(path4);
	segment4 = CGPathCreateCopy(path4);
	CGPathRelease(path4);
		
	CGMutablePathRef path5 = CGPathCreateMutable();
	CGPoint pathPoints5[] = {{2,3}, {2,11}, {4,9}, {4,5}};
	CGPathAddLines(path5, NULL, pathPoints5, 4);
	CGPathCloseSubpath(path5);
	segment5 = CGPathCreateCopy(path5);
	CGPathRelease(path5);
		
	CGMutablePathRef path6 = CGPathCreateMutable();
	CGPoint pathPoints6[] = {{2,13}, {2,21}, {4,19}, {4,15}};
	CGPathAddLines(path6, NULL, pathPoints6, 4);
	CGPathCloseSubpath(path6);
	segment6 = CGPathCreateCopy(path6);
	CGPathRelease(path6);
		
	CGMutablePathRef path7 = CGPathCreateMutable();
	CGPoint pathPoints7[6] = {{3,12}, {4,13}, {10,13}, {11,12}, {10,11}, {4,11}};
	CGPathAddLines(path7, NULL, pathPoints7, 6);
	CGPathCloseSubpath(path7);
	segment7 = CGPathCreateCopy(path7);
	CGPathRelease(path7);
	
	[self size];
		
	return self;
}

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)clockRect
{
	//update current time
	NSTimeInterval time = [self currentTime];
	
	//transform clockRect to standard coordinates
	CGContextTranslateCTM(context, clockRect.origin.x, clockRect.origin.y);
	CGContextScaleCTM(context, clockRect.size.width/size.width, clockRect.size.height/size.height);
	
	//draw background
	CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	
	//draw digits
	NSCalendarDate *date = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:time];
	int hour, minute, second, tenth;
	CGContextSetRGBFillColor(context, 1, 0, 0, 1);
	if (displaysHours)	{
		hour = [date hourOfDay];
		if (hour > 12)
			hour = hour - 12;
		if (hour == 0)
			hour = 12;
		CGContextTranslateCTM(context, -8, 0);
		if (hour > 9)
			[self drawDigit:1 inContext:context];
		CGContextTranslateCTM(context, 16, 0);
		[self drawDigit:(hour % 10) inContext:context];
		CGContextTranslateCTM(context, 14, 0);
	}
	if (displaysHours && displaysMinutes)	{
		CGContextFillRect(context, CGRectMake(2, 7, 2, 2));
		CGContextFillRect(context, CGRectMake(2, 16, 2, 2));
		CGContextTranslateCTM(context, 6, 0);
	}
	if (displaysMinutes)	{
		minute = [date minuteOfHour];
		[self drawDigit:(minute / 10) inContext:context];
		CGContextTranslateCTM(context, 16, 0);
		[self drawDigit:(minute % 10) inContext:context];
		CGContextTranslateCTM(context, 14, 0);
	}
	if (displaysMinutes && displaysSeconds)	{
		CGContextFillRect(context, CGRectMake(2, 7, 2, 2));
		CGContextFillRect(context, CGRectMake(2, 16, 2, 2));
		CGContextTranslateCTM(context, 6, 0);
	}
	if (displaysSeconds)	{
		second = [date secondOfMinute];
		[self drawDigit:(second / 10) inContext:context];
		CGContextTranslateCTM(context, 16, 0);
		[self drawDigit:(second % 10) inContext:context];
		CGContextTranslateCTM(context, 14, 0);
	}
	if (displaysSeconds && displaysTenths)	{
		CGContextFillRect(context, CGRectMake(2, 2, 2, 2));
		CGContextTranslateCTM(context, 6, 0);
	}
	if (displaysTenths)	{
		tenth = (int)(time*10 + 0.5) % 10;
		[self drawDigit:tenth inContext:context];
	}
}

- (void)drawDigit:(int)digit inContext:(CGContextRef)context
{
	switch (digit)	{
	case 0:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		CGContextAddPath(context, segment5);
		CGContextFillPath(context);
		CGContextAddPath(context, segment6);
		CGContextFillPath(context);
		break;
	case 1:
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		break;
	case 2:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		CGContextAddPath(context, segment5);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		break;
	case 3:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		break;
	case 4:
		CGContextAddPath(context, segment6);
		CGContextFillPath(context);
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		break;
	case 5:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment6);
		CGContextFillPath(context);
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		break;
	case 6:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment6);
		CGContextFillPath(context);
		CGContextAddPath(context, segment5);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		break;
	case 7:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		break;
	case 8:
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		CGContextAddPath(context, segment5);
		CGContextFillPath(context);
		CGContextAddPath(context, segment6);
		CGContextFillPath(context);
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		break;
	case 9:
		CGContextAddPath(context, segment7);
		CGContextFillPath(context);
		CGContextAddPath(context, segment6);
		CGContextFillPath(context);
		CGContextAddPath(context, segment1);
		CGContextFillPath(context);
		CGContextAddPath(context, segment2);
		CGContextFillPath(context);
		CGContextAddPath(context, segment3);
		CGContextFillPath(context);
		CGContextAddPath(context, segment4);
		CGContextFillPath(context);
		break;
	}
}

- (NSSize)size
{
	float width = 0;
	
	if (displaysHours)
		width = width + 14 + 8;
	if (displaysMinutes && displaysHours)
		width = width + 6;
	if (displaysMinutes)
		width = width + 14*2 + 2;
	if (displaysSeconds && displaysMinutes)
		width = width + 6;
	if (displaysSeconds)
		width = width + 14*2 + 2;
	if (displaysTenths && displaysSeconds)
		width = width + 6;
	if (displaysTenths)
		width = width + 14;
	
	size = NSMakeSize(width, 24);
	return size;
}

@end
