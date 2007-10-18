//
//  CFilteringCoreImageView.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 11/03/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CFilteringCoreImageView.h"

#import "Geometry.h"

// TODO -- BUGS: Doesn't refresh if filter values modified.

@implementation CFilteringCoreImageView

+ (void)initialize
{
[self exposeBinding:@"filter"];

[self setKeys:[NSArray arrayWithObjects:@"image", @"filter", NULL] triggerChangeNotificationsForDependentKey:@"filteredImage"];
}

#pragma mark -

- (CIImage *)imageToDraw
{
return([self filteredImage]);
}

#pragma mark -

- (CIFilter *)filter
{
return(filter);
}

- (void)setFilter:(CIFilter *)inFilter
{
if (filter != inFilter)
	{
	[filter autorelease];
	filter = [inFilter retain];
	//
	[self setNeedsDisplay:YES];
	}
}

#pragma mark -

- (CIImage *)filteredImage
{
CIImage *theFilteredImage = NULL;
if ([self filter])
	{
	[[self filter] setValue:[self image] forKey:@"inputImage"];
	theFilteredImage = [[self filter] valueForKey:@"outputImage"];
	}
else
	{
	theFilteredImage = [self image];
	}
return(theFilteredImage);
}

@end
