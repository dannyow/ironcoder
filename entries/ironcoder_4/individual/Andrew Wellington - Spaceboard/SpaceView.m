/*
 * Project:     Spaceboard
 * File:        SpaceView.m
 * Author:      Andrew Wellington
 *
 * License:
 * Copyright (C) 2006 Andrew Wellington.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SpaceView.h"

#define SPACE_BOX_RADIUS	25
#define SPACE_BOX_MARGIN	15

@implementation SpaceView
- (void)setString:(NSAttributedString *)aStr
{
	if (str != aStr)
	{
		[str release];
		str = [aStr retain];
	}
}
	
- (void)drawRect:(NSRect)rect
{
	NSRect theRect;
	
	[[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:0.85] set];
	
	theRect = [self frame];
	
	// Algorithm stolen from DrunkVision from a previous IronCoder, which was previously stolen from Growl... :-)
	//This is an algorithm I ganked from Growl. It creates a rectangle with rounded corners inside expandedRect.
	float minX = NSMinX(theRect);
	float minY = NSMinY(theRect);
	float maxX = NSMaxX(theRect);
	float maxY = NSMaxY(theRect);
	float midX = NSMidX(theRect);
	float midY = NSMidY(theRect);
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:(NSPoint){maxX, midY}];
	[path appendBezierPathWithArcFromPoint:(NSPoint){maxX, maxY} toPoint:(NSPoint){midX, maxY} radius:SPACE_BOX_RADIUS]; 
	[path appendBezierPathWithArcFromPoint:(NSPoint){minX, maxY} toPoint:(NSPoint){minX, midY} radius:SPACE_BOX_RADIUS]; 
	[path appendBezierPathWithArcFromPoint:(NSPoint){minX, minY} toPoint:(NSPoint){midX, minY} radius:SPACE_BOX_RADIUS]; 
	[path appendBezierPathWithArcFromPoint:(NSPoint){maxX, minY} toPoint:(NSPoint){maxX, midY} radius:SPACE_BOX_RADIUS]; 
	[path closePath];
	[path fill];
	
	[str drawAtPoint:NSMakePoint(SPACE_BOX_MARGIN, SPACE_BOX_MARGIN)];
}
@end
