//
//  CMyView.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/26/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CMyView.h"

@implementation CMyView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
if ((self = [super initWithCoder:aDecoder]) != NULL)
	{
	ratio = 0.5f;

	compositingFilter = [[CIFilter filterWithName:@"CISourceOverCompositing"] retain];
	}
return(self);
}

- (void)dealloc
{
//
[super dealloc];
}

#pragma mark -
/*
- (void)unlockFocus
{

[super unlockFocus];

[super lockFocus];

[NSGraphicsContext saveGraphicsState];

NSLog(@"%@", [[NSGraphicsContext currentContext] attributes]);
NSLog(@"%@", [[NSGraphicsContext currentContext] graphicsPort]);

NSBezierPath *thePath = [NSBezierPath bezierPathWithOvalInRect:[self bounds]];

[thePath stroke];

[NSGraphicsContext restoreGraphicsState];

[super unlockFocus];

}
*/

- (CIImage *)imageToDraw
{
CIImage *theImage = [self image];
CIImage *theFilteredImage = [self filteredImage];
if (theImage != NULL && theFilteredImage != NULL)
	{
	CGRect theSourceRect, theDestinationRect;
	theSourceRect = theDestinationRect = [theImage extent];
	theDestinationRect.size.width *= ratio;

	[compositingFilter setValue:theFilteredImage forKey:@"inputImage"];
	[compositingFilter setValue:theImage forKey:@"inputBackgroundImage"];
	theImage = [compositingFilter valueForKey:@"outputImage"];
	}
return(theImage);
}

#pragma mark -

- (float)ratio
{
return(ratio);
}

- (void)setRatio:(float)inRatio
{
ratio = inRatio;
[self setNeedsDisplay:YES];
}

@end