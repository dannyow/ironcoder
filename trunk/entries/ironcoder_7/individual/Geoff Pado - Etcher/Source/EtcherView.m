//
//  EtcherView.m
//  Etcher
//
//  Created by Geoff Pado on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "EtcherView.h"
#import "RoundRect.h"

@implementation EtcherView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
		drawPath = [NSBezierPath bezierPath];
		[drawPath moveToPoint:NSMakePoint(320,240)];
		[drawPath retain];
		strokeColor = [NSColor blackColor];
	}
    return self;
}

- (void)drawRect:(NSRect)rect 
{
	[[NSColor grayColor] set];
	[[NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0] fill];
	
	[strokeColor set];
	[drawPath stroke];
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSPoint currentPoint = [drawPath currentPoint];
	NSPoint newPoint;
	
	switch ([theEvent keyCode])
	{
		case 123:
			newPoint = NSMakePoint((currentPoint.x - 1), currentPoint.y);
			[delegate spinDial:@"x" distance:+1];
			if (NSPointInRect(newPoint, [self frame]))
				[drawPath lineToPoint:newPoint];
			break;
		case 124:
			newPoint = NSMakePoint((currentPoint.x + 1), currentPoint.y);
			[delegate spinDial:@"x" distance:-1];
			if (NSPointInRect(newPoint, [self frame]))
				[drawPath lineToPoint:newPoint];
			break;
		case 125:
			newPoint = NSMakePoint(currentPoint.x, (currentPoint.y - 1));
			[delegate spinDial:@"y" distance:-1];
			if (NSPointInRect(newPoint, [self frame]))
				[drawPath lineToPoint:newPoint];
			break;
		case 126:
			newPoint = NSMakePoint(currentPoint.x, (currentPoint.y + 1));
			[delegate spinDial:@"y" distance:+1];
			if (NSPointInRect(newPoint, [self frame]))
				[drawPath lineToPoint:newPoint];
			break;
		default:
			break;
	}
	[self display];
}

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)aValue
{
	id oldDelegate = delegate;
	delegate = [aValue retain];
	[oldDelegate release];
}

- (void)dropOpacity
{
	float alpha = [strokeColor alphaComponent];
	strokeColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:(alpha - 0.05)];
	[strokeColor retain];
	[self display];
}

- (void)clearPath
{
	NSPoint currentPoint = [drawPath currentPoint];
	NSBezierPath *newPath = [NSBezierPath bezierPath];
	[newPath moveToPoint:currentPoint];
	[drawPath release];
	[newPath retain];
	drawPath = newPath;
	strokeColor = [[NSColor blackColor] retain];
}

@end
