//
//  CIImage_Extensions.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/27/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "CIImage_Extensions.h"

#import "Geometry.h"

@implementation CIImage (CIImage_Extensions)

+ (CIImage *)placeholderImage
{
CIFilter *theFilter = [CIFilter filterWithName:@"CICheckerboardGenerator"];
[theFilter setDefaults];
return([theFilter valueForKey:@"outputImage"]);
}

+ (CIImage *)emptyImage
{
CIFilter *theFilter = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", [CIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f], NULL];
return([theFilter valueForKey:@"outputImage"]);
}

+ (CIImage *)imageWithNSImage:(NSImage *)inNSImage
{
NSData *theTIFFImageData = [inNSImage TIFFRepresentation];
CIImage *theImage = [CIImage imageWithData:theTIFFImageData];
return(theImage);
}

+ (CIImage *)imageNamed:(NSString *)inName
{
NSImage *theImage = [NSImage imageNamed:inName];
return([self imageWithNSImage:theImage]);
}

#pragma mark -

- (NSImage *)asNSImage
{
CGSize theSize = [self extent].size;
NSImage *theNSImage = [[[NSImage alloc] initWithSize:NSMakeSize(theSize.width, theSize.height)] autorelease];
[theNSImage addRepresentation:[NSCIImageRep imageRepWithCIImage:self]];
return(theNSImage);
}

- (NSImage *)asNSImageOfSize:(CGSize)inSize
{
CIImage *theImage = [self scaleToSize:inSize];
NSImage *theNSImage = [[[NSImage alloc] initWithSize:NSMakeSize(inSize.width, inSize.height)] autorelease];
[theNSImage addRepresentation:[NSCIImageRep imageRepWithCIImage:theImage]];
return(theNSImage);
}

- (NSBitmapImageRep *)asBitmapImageRep
{
CGRect theExtent = [self extent];
NSBitmapImageRep *theBitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:theExtent.size.width
pixelsHigh:theExtent.size.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];

// Create an NSGraphicsContext that draws into the NSBitmapImageRep. (This capability is new in Tiger.)
NSGraphicsContext *theGraphicsContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:theBitmapImageRep];

// Save the previous graphics context and state, and make our bitmap context current.
[NSGraphicsContext saveGraphicsState];
[NSGraphicsContext setCurrentContext:theGraphicsContext];

// Get a CIContext from the NSGraphicsContext, and use it to draw the CIImage into the NSBitmapImageRep.
[[theGraphicsContext CIContext] drawImage:self inRect:theExtent fromRect:theExtent];

// Restore the previous graphics context and state.
[NSGraphicsContext restoreGraphicsState];

return(theBitmapImageRep);
}

- (CGImageRef)asCGImage
{
CGRect theExtent = [self extent];

if (theExtent.size.width <= 0.0 || theExtent.size.height <= 0.0) [NSException raise:NSGenericException format:@"Cannot create CGImage from CIImage with zero extents"];

const size_t theRowBytes = theExtent.size.width * 4;
const size_t theSize = theRowBytes * theExtent.size.height;

NSMutableData *theData = [NSMutableData dataWithLength:theSize];
if (theData == NULL) [NSException raise:NSGenericException format:@"Could not create data."];

CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
if (theColorSpace == NULL) [NSException raise:NSGenericException format:@"CGColorSpaceCreateDeviceRGB() failed."];

CGContextRef theBitmapContext = CGBitmapContextCreate([theData mutableBytes], theExtent.size.width, theExtent.size.height, 8, theRowBytes, theColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
if (theBitmapContext == NULL) [NSException raise:NSGenericException format:@"theBitmapContext() failed."];

CIContext *theCoreImageContext = [CIContext contextWithCGContext:theBitmapContext options:0];
if (theCoreImageContext == NULL) [NSException raise:NSGenericException format:@"Coult not create CIContext"];

[theCoreImageContext drawImage:self inRect:theExtent fromRect:theExtent];
CFRelease(theBitmapContext);

CGDataProviderRef theDataProvider = CGDataProviderCreateWithData(NULL, [theData mutableBytes], [theData length], NULL);
if (theDataProvider == NULL) [NSException raise:NSGenericException format:@"CGDataProviderCreateWithData() failed."];

CGImageRef theCGImage = CGImageCreate(theExtent.size.width, theExtent.size.height, 8, 32, theRowBytes, theColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst, theDataProvider, NULL, NO, kCGRenderingIntentDefault);
if (theCGImage == NULL) [NSException raise:NSGenericException format:@"CGImageCreate() failed."];

CFRelease(theDataProvider);

CFRelease(theColorSpace);

return(theCGImage);
}

#pragma mark -

- (CIImage *)flippedHorizontally
{
// Flip and slide baby, flip and slide.
// TODO what about images with infinite extent?
NSAffineTransform *theTransform = [NSAffineTransform transform];
[theTransform scaleXBy:-1.0 yBy:1.0];
[theTransform translateXBy:[self extent].size.width yBy:0.0f];
CIFilter *theFilter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:@"inputImage", self, @"inputTransform", theTransform, NULL];
CIImage *theImage = [theFilter valueForKey:@"outputImage"];
return(theImage);
}

- (CIImage *)cropToSize:(CGSize)inSize
{
CIVector *theCropVector = [CIVector vectorWithX:0.0 Y:0.0 Z:inSize.width W:inSize.height];
CIFilter *theFilter = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", self, @"inputRectangle", theCropVector, NULL];
CIImage *theImage = [theFilter valueForKey:@"outputImage"];
return(theImage);
}

- (CIImage *)scaleToSize:(CGSize)inSize
{
// Based on Dan Wood's code: http://www.gigliwood.com/weblog/Cocoa/Core_Image,_part_2.html?seemore=y

// Clamp the edges of the image (to prevent fractional pixels from being generated at the edge of the image when we scale)
CIFilter *theFilter = [CIFilter filterWithName:@"CIAffineClamp" keysAndValues:@"inputTransform", [NSAffineTransform transform], @"inputImage", self, NULL];
CIImage *theImage = [theFilter valueForKey:@"outputImage"];
// Scale...
const CGSize theOriginalSize = [self extent].size; // TODO what if it is already infinite?
const float theScale = inSize.height / theOriginalSize.height;
const float theAspectRatio = (theOriginalSize.height / theOriginalSize.width) / (inSize.height / inSize.width);
theFilter = [CIFilter filterWithName:@"CILanczosScaleTransform" keysAndValues:@"inputScale", [NSNumber numberWithFloat:theScale], @"inputAspectRatio", [NSNumber numberWithFloat:theAspectRatio], @"inputImage", theImage, NULL];
theImage = [theFilter valueForKey:@"outputImage"];
// Crop...
CIVector *theCropVector = [CIVector vectorWithX:0.0 Y:0.0 Z:inSize.width W:inSize.height];
theFilter = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", theImage, @"inputRectangle", theCropVector, NULL];
theImage = [theFilter valueForKey:@"outputImage"];
return(theImage);
}

- (CIImage *)scaleToSize:(CGSize)inSize maintainAspectRatio:(BOOL)inMaintainAspectRatio
{
if (inMaintainAspectRatio == NO)
	return([self scaleToSize:inSize]);
else
	{
	NSRect theImageRect = NSRectFromCGRect([self extent]);
	NSRect theDesiredRect = { .origin = NSZeroPoint, .size = NSSizeFromCGSize(inSize) };
	NSRect theDestinationRect = ScaleImageRectToRect(theImageRect, theDesiredRect, NSScaleProportionally, NSImageAlignCenter);
	return([self scaleToSize:CGSizeFromNSSize(theDestinationRect.size)]);	
	}
}

- (CIImage *)gaussianBlurred:(float)inRadius
{
CIFilter *theFilter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputImage", self, @"inputRadius", [NSNumber numberWithFloat:inRadius], NULL];
CIImage *theImage = [theFilter valueForKey:@"outputImage"];
NSLog(@"%@", theImage);
return(theImage);
}

@end
