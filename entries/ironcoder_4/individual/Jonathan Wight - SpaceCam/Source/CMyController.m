//
//  CMyController.m
//  Space
//
//  Created by Jonathan Wight on 10/28/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "CMyController.h"

#import "CInvocationGrabber.h"
#import "CFlickrFeed.h"
#import "CImageAverager.h"
#import "CGenericCIFilter.h"

@implementation CMyController

- (id)init
{
if ((self = [super init]) != NULL)
	{
	[CGenericCIFilter initialize];
	
	flickrFeed = [[CFlickrFeed alloc] init];
	imageAverager = [[CImageAverager alloc] init];
	}
return(self);
}


- (void)awakeFromNib
{
[self bind:@"sourceImage" toObject:outletSequenceGrabber withKeyPath:@"image" options:NULL];

[self bind:@"scenaryImage" toObject:flickrFeed withKeyPath:@"coreImage" options:NULL];


[self setImageMode:ImageMode_Inactive];

[outletSequenceGrabber start:self];
}

#pragma mark -

- (EImageMode)imageMode
{
return imageMode;
}

- (void)setImageMode:(EImageMode)inImageMode
{
imageMode = inImageMode;
}

- (CIImage *)sourceImage
{
return(sourceImage); 
}

- (void)setSourceImage:(CIImage *)inSourceImage
{
if (sourceImage != inSourceImage)
    {
	[sourceImage autorelease];
	sourceImage = [inSourceImage retain];

	if ([self imageMode] == ImageMode_Inactive)
		{
		[self setOutputImage:inSourceImage];
		}
	else if ([self imageMode] == ImageMode_Gathering)
		{
		[self setBackgroundImage:inSourceImage];
		}
	else if ([self imageMode] == ImageMode_Displaying)
		{
		CIFilter *theFilter = [self backgroundReplacerFilter];

		[theFilter setDefaults];
		[theFilter setValue:[[self backgroundImage] gaussianBlurred:10.0f] forKey:@"oldBackgroundImage"];
		[theFilter setValue:[self scenaryImage] forKey:@"newBackgroundImage"];
		[theFilter setValue:inSourceImage forKey:@"image"];
		
		CIImage *theFilteredImage = [theFilter valueForKey:@"outputImage"];
		
		theFilteredImage = [theFilteredImage cropToSize:[inSourceImage extent].size];
		
		[self setOutputImage:theFilteredImage];
		}
	}
}

- (CIImage *)backgroundImage
{
return(backgroundImage); 
}

- (void)setBackgroundImage:(CIImage *)inBackgroundImage
{
if (backgroundImage != inBackgroundImage)
    {
//	[imageAverager addImage:inBackgroundImage];
//	backgroundImage = [imageAverager averageImage];

	[backgroundImage autorelease];
	backgroundImage = [inBackgroundImage retain];

	[self setOutputImage:inBackgroundImage];
    }
}

- (CIImage *)scenaryImage
{
return(scenaryImage); 
}

- (void)setScenaryImage:(CIImage *)inScenaryImage
{
if (scenaryImage != inScenaryImage)
    {
	[scenaryImage autorelease];
	scenaryImage = [[inScenaryImage scaleToSize:CGSizeMake(640,480) maintainAspectRatio:YES] retain];
    }
}

- (CIImage *)outputImage
{
return(outputImage); 
}

- (void)setOutputImage:(CIImage *)inOutputImage
{
if (outputImage != inOutputImage)
    {
	[outputImage autorelease];
	outputImage = [inOutputImage retain];
    }
}

- (CIFilter *)backgroundReplacerFilter
{
if (backgroundReplacerFilter == NULL)
	{
	CIFilter *theFilter = [CIFilter filterWithName:@"GenericFilter"];
	[theFilter setDefaults];
	NSString *theKernel = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundReplacer" ofType:@"cikernel"]];
	[theFilter setValue:theKernel forKey:@"inputKernel"];
	NSArray *theParameterNames = [NSArray arrayWithObjects:@"oldBackgroundImage", @"newBackgroundImage", @"image", NULL];
	[theFilter setValue:theParameterNames forKey:@"inputKernelParameterNames"];

	backgroundReplacerFilter = [theFilter retain];
	}
return(backgroundReplacerFilter); 
}

#pragma mark -

- (IBAction)actionGatherBackground:(id)inSender
{
#pragma unused (inSender)

[self setImageMode:ImageMode_Gathering];

CInvocationGrabber *theInvocationGrabber = [CInvocationGrabber invocationGrabber];
[[theInvocationGrabber prepareWithInvocationTarget:self] setImageMode:ImageMode_Displaying];

NSTimer *theTimer = [NSTimer timerWithTimeInterval:5.0f invocation:[theInvocationGrabber invocation] repeats:NO];

[[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSDefaultRunLoopMode];
[[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSEventTrackingRunLoopMode];
}

@end
