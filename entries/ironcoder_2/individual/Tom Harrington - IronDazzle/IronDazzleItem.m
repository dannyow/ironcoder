//
//  IronDazzleItem.m
//  IronDazzle
//
//  Created by Tom Harrington on 7/22/06.
//  Copyright 2006 Tom Harrington. All rights reserved.
//

#import "IronDazzleItem.h"


@implementation IronDazzleItem

- (id)initWithLocation:(CGPoint)newLocation vector:(CGPoint)newVector originalScreenLocation:(NSPoint)originalLocation
{
	if (self = [super init]) {
		rect.origin = newLocation;
//		location = newLocation;
		vector = newVector;
		originalScreenLocation = originalLocation;
		previousScreenLocation = originalLocation;
	}
	return self;
}

- (void)moveWithCurrentScreenOrigin:(NSPoint)screenLocation
{
	// update point by vector
	rect.origin.x += vector.x;
	rect.origin.y += vector.y;
	// Account for mouse movement
	rect.origin.x -= (screenLocation.x - previousScreenLocation.x);
	rect.origin.y -= (screenLocation.y - previousScreenLocation.y);
	previousScreenLocation = screenLocation;
}

- (CGPoint)location
{
	return rect.origin;
}

- (CGRect)rect
{
	return rect;
}

- (void)drawLayer:(CGLayerRef)layer inContext:(CGContextRef)context
{
	CGContextDrawLayerAtPoint(context, rect.origin, layer);
	rect.size = CGLayerGetSize(layer);
}
/*
- (void)drawInContext:(NSGraphicsContext *)nsctx
{
	CGContextRef context = (CGContextRef)[nsctx graphicsPort];
	// Now draw in context at updated location (this is where the clock image needs to come into play)
	CGRect myRect;
	
	myRect.origin.x = rect.origin.x;
	myRect.origin.y = rect.origin.y;
	myRect.size.width = 5.0;
	myRect.size.height = 5.0;
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextFillRect(context, myRect);
}
*/
@end
