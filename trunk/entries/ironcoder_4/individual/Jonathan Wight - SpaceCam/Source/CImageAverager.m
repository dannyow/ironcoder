//
//  CImageAverager.m
//  Space
//
//  Created by Jonathan Wight on 10/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CImageAverager.h"

#import "CIImage_Extensions.h"

@implementation CImageAverager

- (void)dealloc
{
[self setAverageImage:NULL];
[weightingFilter autorelease];
weightingFilter = NULL;
//
[super dealloc];
}

- (CIImage *)averageImage
{
return(averageImage); 
}

- (void)setAverageImage:(CIImage *)inAverageImage
{
if (averageImage != inAverageImage)
    {
	[averageImage autorelease];
	averageImage = [inAverageImage retain];
    }
}

- (unsigned)count
{
return(count);
}

- (void)setCount:(unsigned)inCount
{
count = inCount;
}

- (void)addImage:(CIImage *)inImage
{
++count;

if (count == 1)
	{
	[self setAverageImage:inImage];
	}
else
	{
	CIFilter *theFilter = [self weightingFilter];

	CIImage *theAverageImage = [self averageImage];

	[theFilter setValue:theAverageImage forKey:@"inputImage0"];
	[theFilter setValue:[NSNumber numberWithDouble:(double)(count - 1) / (double)count] forKey:@"inputWeight0"];
	[theFilter setValue:inImage forKey:@"inputImage1"];
	[theFilter setValue:[NSNumber numberWithDouble:1.0 / (double)count] forKey:@"inputWeight1"];

	CIImage *theOutputImage = [theFilter valueForKey:@"outputImage"];
	theOutputImage = [theOutputImage cropToSize:[inImage extent].size];
	theOutputImage = [CIImage imageWithCGImage:[theOutputImage asCGImage]];

	[self setAverageImage:theOutputImage];
	}
}

- (CIFilter *)weightingFilter
{
if (weightingFilter == NULL)
	{
	CIFilter *theFilter = [CIFilter filterWithName:@"GenericFilter"];
	[theFilter setDefaults];
	NSString *theKernel = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Weighting" ofType:@"cikernel"]];
	[theFilter setValue:theKernel forKey:@"inputKernel"];
	NSArray *theParameterNames = [NSArray arrayWithObjects:@"inputImage0", @"inputWeight0", @"inputImage1", @"inputWeight1", NULL];
	[theFilter setValue:theParameterNames forKey:@"inputKernelParameterNames"];

	weightingFilter = [theFilter retain];
	}
return(weightingFilter);
}


@end
