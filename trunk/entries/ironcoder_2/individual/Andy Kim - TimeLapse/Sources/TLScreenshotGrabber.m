//
//  TLScreenshotTaker.m
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "TLScreenshotGrabber.h"
#import "TLDefines.h"

@implementation TLScreenshotGrabber

+ (TLScreenshotGrabber*)grabber
{
	static id grabber = nil;
	if (grabber == nil)
	{
		grabber = [[TLScreenshotGrabber alloc] init];
	}
	return grabber;
}

- (id)init
{
	if (self = [super init])
	{
		CGDirectDisplayID display = CGMainDisplayID();
		int screenHeight = CGDisplayPixelsHigh(display);
		int bytesPerRow = CGDisplayBytesPerRow(display);
		
		mImageBuffer = malloc(screenHeight * bytesPerRow);
	}
	return self;
}

- (NSData*)screenshotImageData
{
	// Phase 1: Get the raw screen data into an acceptable format
	CGDirectDisplayID display = CGMainDisplayID();

	int bytesPerRow = CGDisplayBytesPerRow(kCGDirectMainDisplay);
	
	UInt32 *frameBuffer = CGDisplayBaseAddress(display);

	int width = CGDisplayPixelsWide(display);
	int height = CGDisplayPixelsHigh(display);

	int bytesize = height * bytesPerRow;

	for (int row = 0; row < height; row++)
	{
		for (int col = 0; col < width; col++)
		{
			UInt32 *src = frameBuffer + (row * bytesPerRow/4) + col;
			UInt32 *dst = mImageBuffer + (row * bytesPerRow/4) + col;
			*dst = *src << 8;
		}
	}


	// Phase 2: Save into an NSData object
	NSData *bufferData = [[NSData dataWithBytesNoCopy:mImageBuffer length:bytesize freeWhenDone:NO] retain];

	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)bufferData);

	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	
	CGImageRef bigImage = CGImageCreate(width, //size_t width,
										height, //size_t height,
										8, //size_t bitsPerComponent,
										32, //size_t bitsPerPixel,
										bytesPerRow, //screenWidth * 4, //size_t bytesPerRow,
										colorspace, //CGColorSpaceRef colorspace,
										kCGBitmapByteOrder32Host, //CGBitmapInfo bitmapInfo,
										provider, //CGDataProviderRef provider,
										NULL, //const float decode[],
										0, //int shouldInterpolate,
										kCGRenderingIntentDefault); //CGColorRenderingIntent intent

	NSMutableData *bigImageDestinationData = [NSMutableData data];
	
	CGImageDestinationRef bigImageDestination = CGImageDestinationCreateWithData((CFMutableDataRef)bigImageDestinationData,
																				 kUTTypeJPEG, //CFStringRef type, 
																				 1, //size_t count, 
																				 NULL); //CFDictionaryRef options);

	NSAssert(bigImageDestination != NULL, @"image destination should not be NULL");

	CGImageDestinationAddImage(bigImageDestination, bigImage, NULL);
	CGImageDestinationFinalize(bigImageDestination);

	CFRelease(provider);
	CFRelease(colorspace);
	CFRelease(bigImage);
	CFRelease(bigImageDestination);

	// Phase 3: Using the image data, scale down the screenshot so that the performance is acceptable on huge displays
	NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
													  [NSNumber numberWithFloat:MAX_SCREENSHOT_WIDTH], kCGImageSourceThumbnailMaxPixelSize,
												   kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
												   kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageIfAbsent,
												   nil];
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)bigImageDestinationData, NULL);//(CFDictionaryRef)sourceOptions);
	NSAssert(imageSource != nil, @"image source must not be NULL");
	CGImageRef image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)thumbnailOptions);
	NSAssert(image != nil, @"image must not be NULL");

	NSMutableData *imageDestinationData = [NSMutableData data];
	
	CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((CFMutableDataRef)imageDestinationData,
																			  kUTTypeJPEG, //CFStringRef type, 
																			  1, //size_t count, 
																			  NULL); //CFDictionaryRef options);
	NSAssert(imageDestination != nil, @"image destination must not be NULL");
	
	CGImageDestinationAddImage(imageDestination, image, NULL);
	CGImageDestinationFinalize(imageDestination);

	CFRelease(image);
	CFRelease(imageDestination);

	return (NSData*)imageDestinationData;
}

@end
