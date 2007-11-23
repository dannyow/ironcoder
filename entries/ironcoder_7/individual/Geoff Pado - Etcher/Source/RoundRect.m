//
//  RoundRect.m
//  Etcher
//
//  Created by Geoff Pado on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RoundRect.h"


@implementation NSBezierPath (RoundRect)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius
{
	NSBezierPath *result = [NSBezierPath bezierPath];
	[result appendBezierPathWithRoundedRect:rect cornerRadius:radius];
	return result;
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius
{
    if (!NSIsEmptyRect(rect)) 
	{
  		if (radius > 0.0) 
		{
			// Clamp radius to be no larger than half the rect's width or height.
			float clampedRadius = MIN(radius, 0.5 * MIN(rect.size.width, rect.size.height));

			NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
			NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
			NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));

			[self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
			[self appendBezierPathWithArcFromPoint:topLeft toPoint:rect.origin radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:rect.origin toPoint:bottomRight radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:bottomRight toPoint:topRight radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:topRight toPoint:topLeft radius:clampedRadius];
			[self closePath];
		} 
		
		else 
		{
			// When radius == 0.0, this degenerates to the simple case of a plain rectangle.
			[self appendBezierPathWithRect:rect];
		}
	}
}



@end
