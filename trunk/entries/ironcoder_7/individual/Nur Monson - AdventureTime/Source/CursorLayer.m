//
//  CursorLayer.m
//  AdventureTime
//
//  Created by Nur Monson on 11/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "CursorLayer.h"


@implementation CursorLayer

- (void)drawInContext:(CGContextRef)cxt
{
	CGRect bounds = CGContextGetClipBoundingBox(cxt);
	CGContextSetRGBFillColor(cxt, 1.0f, 1.0f, 1.0f, 0.8f);
	CGContextAddEllipseInRect(cxt, bounds);
	CGContextFillPath(cxt);
	/*
	//CGContextSetLineWidth(cxt, 2.0f);
	//CGColorRef black = CGColorCreateGenericGray(0.0f, 1.0f);
	CGColorRef white = CGColorCreateGenericGray(1.0f, 1.0f);
	
	bounds = CGRectInset(bounds, 4.0f, 4.0f);
	int i;
	for( i=0; !CGRectIsEmpty(bounds); i++ ) {
		if( i & 1 )
			CGContextSetStrokeColorWithColor(cxt, black);
		else
			CGContextSetStrokeColorWithColor(cxt, white);
		CGContextAddEllipseInRect(cxt, bounds);
		CGContextStrokePath(cxt);
		
		bounds = CGRectInset(bounds, 4.0f, 4.0f);
	}
	 */
}

@end
