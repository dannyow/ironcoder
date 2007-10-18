//
//  Geometry.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/15/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

extern NSRect ScaleImageRectToRect(NSRect inImageRect, NSRect inDestinationRect, NSImageScaling inScaling, NSImageAlignment inAlignment);

static inline CGRect CGRectFromNSRect(NSRect inRect)
{
//return(*(CGRect *)&inRect);
CGRect theRect = { .origin = { .x = inRect.origin.x, .y = inRect.origin.y }, .size = { .width = inRect.size.width, .height = inRect.size.height } };
return(theRect);
}

static inline NSRect NSRectFromCGRect(CGRect inRect)
{
//return(*(NSRect *)&inRect);
NSRect theRect = { .origin = { .x = inRect.origin.x, .y = inRect.origin.y }, .size = { .width = inRect.size.width, .height = inRect.size.height } };
return(theRect);
}

static inline CGPoint CGPointFromNSPoint(NSPoint inPoint)
{
//return(*(CGPoint *)&inPoint);
CGPoint thePoint = { .x = inPoint.x, .y = inPoint.y };
return(thePoint);
}

static inline CGSize CGSizeFromNSSize(NSSize inSize)
{
//return(*(CGSize *)&inSize);
CGSize theSize = { .width = inSize.width, .height = inSize.height };
return(theSize);
}

static inline NSSize NSSizeFromCGSize(CGSize inSize)
{
//return(*(NSSize *)&inSize);
NSSize theSize = { .width = inSize.width, .height = inSize.height };
return(theSize);
}

#pragma mark -

static inline NSRect NSScaleRect(NSRect inRect, float inXScale, float inYScale)
{
NSRect theScaledRect = {
	.origin = { inRect.origin.x * inXScale, inRect.origin.y * inYScale},
	.size = { inRect.size.width * inXScale, inRect.size.height * inYScale }
	};
return(theScaledRect);
}

static inline CGRect CGScaleRect(CGRect inRect, float inXScale, float inYScale)
{
CGRect theScaledRect = {
	.origin = { inRect.origin.x * inXScale, inRect.origin.y * inYScale},
	.size = { inRect.size.width * inXScale, inRect.size.height * inYScale }
	};
return(theScaledRect);
}

static inline NSPoint NSScalePoint(NSPoint inPoint, float inXScale, float inYScale)
{
NSPoint thePoint = { .x = inPoint.x * inXScale, .y = inPoint.y * inYScale };
return(thePoint);
}

static inline NSPoint NSCenterRect(NSRect inRect)
{
NSPoint thePoint = { .x = NSMidX(inRect), .y = NSMidY(inRect) };
return(thePoint);
}

#pragma mark -

static inline NSRect NSRectFromCarbonRect(Rect inRect)
{
// TODO what about the old flipped vertical thing?
return(NSMakeRect(inRect.left, inRect.top, inRect.right - inRect.left, inRect.bottom - inRect.top));
}

static inline CIVector *CIVectorFromNSRect(NSRect inRect)
{
return([CIVector vectorWithX:inRect.origin.x Y:inRect.origin.y Z:inRect.size.width W:inRect.size.height]);
}

static inline CIVector *CIVectorFromCGRect(CGRect inRect)
{
return([CIVector vectorWithX:inRect.origin.x Y:inRect.origin.y Z:inRect.size.width W:inRect.size.height]);
}


extern NSString *NSStringFromCarbonRect(Rect inRect);
