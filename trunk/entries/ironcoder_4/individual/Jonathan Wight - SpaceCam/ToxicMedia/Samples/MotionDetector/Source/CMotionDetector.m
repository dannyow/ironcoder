//
//  CMotionDetector.m
//  MotionDetector
//
//  Created by Jonathan Wight on 08/18/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CMotionDetector.h"

#import <ToxicMedia/ToxicMedia.h>

@implementation CMotionDetector

+ (void)initialize
{
[CGenericCIFilter initialize];

[self setKeys:[NSArray arrayWithObjects:@"currentImage", NULL] triggerChangeNotificationsForDependentKey:@"previousImage"];
[self setKeys:[NSArray arrayWithObjects:@"currentImage", @"previousImage", NULL] triggerChangeNotificationsForDependentKey:@"sensorImage"];
[self setKeys:[NSArray arrayWithObjects:@"currentImage", @"sensorImage", NULL] triggerChangeNotificationsForDependentKey:@"highlightedImage"];
[self setKeys:[NSArray arrayWithObjects:@"currentImage", NULL] triggerChangeNotificationsForDependentKey:@"differenceRate"];
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	NSArray *theArray = [NSArray arrayWithObjects:
		[[NSBundle bundleForClass:[self class]] builtInPlugInsPath],
		@"WeightingImageUnit.plugin",
		NULL];
	NSURL *thePathURL = [NSURL fileURLWithPath:[NSString pathWithComponents:theArray]];
	[CIPlugIn loadPlugIn:thePathURL allowNonExecutable:YES];
	[CIPlugIn loadAllPlugIns];
	}
return(self);
}

- (void)dealloc
{
[self setCurrentImage:NULL];
//
[previousImage autorelease];
previousImage = NULL;
//
[differenceFilter autorelease];
differenceFilter = NULL;
//
[super dealloc];
}

#pragma mark -

- (CIImage *)currentImage
{
return(currentImage);
}

- (void)setCurrentImage:(CIImage *)inCurrentImage
{
if (currentImage != inCurrentImage)
	{
	// The current image has changed so the sensor image must be out of date...
	[sensorImage autorelease];
	sensorImage = NULL;
	
	// Hey we have a new image! That means the current image is now the previous image...
	[previousImage autorelease];
	previousImage = [currentImage retain];
	
	[currentImage release];
	currentImage = [inCurrentImage retain];
	}
}

#pragma mark -

- (CIFilter *)differenceFilter
{
if (differenceFilter == NULL)
	{
	CIFilter *theFilter = [CIFilter filterWithName:@"GenericFilter"];
	[theFilter setDefaults];
	NSString *theKernel = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Difference" ofType:@"cikernel"]];
	[theFilter setValue:theKernel forKey:@"inputKernel"];
	NSArray *theParameterNames = [NSArray arrayWithObjects:@"inputImage1", @"inputImage2", NULL];
	[theFilter setValue:theParameterNames forKey:@"inputKernelParameterNames"];
	//
	differenceFilter = [theFilter retain];
	}
return(differenceFilter);
}

#pragma mark -

- (CIImage *)sensorImage
{
if (sensorImage == NULL)
	{
	CIImage *theImage = NULL;
	if (previousImage != NULL)
		{
		[[self differenceFilter] setValue:previousImage forKey:@"inputImage1"];
		[[self differenceFilter] setValue:[self currentImage] forKey:@"inputImage2"];
		theImage = [[self differenceFilter] valueForKey:@"outputImage"];
		const CGSize theSize = [[self currentImage] extent].size;
		theImage = [theImage cropToSize:theSize];
		}
	sensorImage = [theImage retain];
	
	@synchronized(self)
		{
		if (calculatingDifferenceRate == NO)
			{
			[NSThread detachNewThreadSelector:@selector(calculateDifferenceRateThreadMain:) toTarget:self withObject:NULL];
			}
		}
	}
return(sensorImage);
}

- (CIImage *)highlightedImage
{
CIImage *theImage = NULL;
if ([self sensorImage] != NULL)
	{
	CIFilter *theFilter = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", [CIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f], NULL];
	CIImage *theColorImage = [theFilter valueForKey:@"outputImage"];
	theFilter = [CIFilter filterWithName:@"CIMinimumCompositing" keysAndValues:@"inputImage", theColorImage, @"inputBackgroundImage", [self sensorImage], NULL];
	theImage = [theFilter valueForKey:@"outputImage"];

	theFilter = [CIFilter filterWithName:@"CIAdditionCompositing" keysAndValues:@"inputImage", theImage, @"inputBackgroundImage", [self currentImage], NULL];
	theImage = [theFilter valueForKey:@"outputImage"];

	const CGSize theSize = [[self sensorImage] extent].size;
	theImage = [theImage cropToSize:theSize];
	}
return(theImage);
}

#pragma mark -

- (float)differenceRate
{
return(differenceRate);
}

- (void)setDifferenceRate:(float)inDifferenceRate;
{
differenceRate = inDifferenceRate;
}

- (void)setDifferenceRate2:(NSNumber *)inDifferenceRate
{
[self setDifferenceRate:[inDifferenceRate floatValue]];
}

#pragma mark -

- (void)calculateDifferenceRateThreadMain:(id)inParameter
{
NSAutoreleasePool *theAutoreleasePool = [[NSAutoreleasePool alloc] init];
//
@synchronized(self)
	{
	calculatingDifferenceRate = YES;
	}

float theDifferenceRate = 0.0f;
CIImage *theSensorImage = NULL;
CGSize theSensorImageSize;
@synchronized(sensorImage)
	{
	theSensorImage = [self sensorImage];
	theSensorImageSize = [theSensorImage extent].size;
	}
if (theSensorImage != NULL) 
	{
	const CGSize theBitmapSize = theSensorImageSize; // [theImage extent].size;
//	const CGSize theBitmapSize = { 128, 128 };
	NSMutableData *theData = [NSMutableData dataWithLength:theBitmapSize.width * theBitmapSize.height * sizeof(float)];

	CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef theCGContext = CGBitmapContextCreate([theData mutableBytes], theBitmapSize.width, theBitmapSize.height, sizeof(float) * 8, theBitmapSize.width * sizeof(float), theColorSpace, kCGBitmapFloatComponents | kCGBitmapByteOrder32Little);
	CFRelease(theColorSpace);

	NSDictionary *theCIContextOptions = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], kCIContextUseSoftwareRenderer,
		NULL];
	CIContext *theCIContext = [CIContext contextWithCGContext:theCGContext options:theCIContextOptions];
	NSLog(@"%@", theCIContext);
	CGRect theSourceBounds = { .origin = CGPointZero, .size = theSensorImageSize };
	CGRect theDestinationBounds = { .origin = CGPointZero, .size = theBitmapSize };
	NSLog(@"%g %g", theBitmapSize.width, theBitmapSize.height);
	NSLog(@"%@", theSensorImage);
	[theCIContext drawImage:theSensorImage inRect:theDestinationBounds fromRect:theSourceBounds];
	CFRelease(theCGContext);
	
	float *theFloatPointer = (float *)[theData bytes];
	const int theFloatCount = [theData length] / sizeof(float);
	float theTotal = 0.0f;
	
	for (int N = 0; N != theFloatCount; ++N)
		{
		theTotal += *theFloatPointer++;
		}
		
	theDifferenceRate = theTotal / (theBitmapSize.width * theBitmapSize.height);
	[self performSelectorOnMainThread:@selector(setDifferenceRate2:) withObject:[NSNumber numberWithFloat:theDifferenceRate] waitUntilDone:NO];
	}
//
@synchronized(self)
	{
	calculatingDifferenceRate = NO;
	}
//
[theAutoreleasePool release];
}

@end
