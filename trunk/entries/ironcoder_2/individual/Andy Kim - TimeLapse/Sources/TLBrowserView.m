//
//  TLBrowserView.m
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "TLBrowserView.h"
#import "TLDefines.h"
#import "TLPrintView.h"
#import "TimeLapse_AppDelegate.h"

@implementation TLBrowserView

// Number of pixels to draw to the right of a screenshot thumbnail
#define RIGHT_MARGIN 5

#pragma mark Initialization

+ (void)initialize
{
	[self exposeBinding:@"zoomFactor"];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		mZoomFactor = MIN_ZOOM_FACTOR / 100.0;
    }
    return self;
}

#pragma mark Accessors

- (float)zoomFactor { return mZoomFactor * 100.0; }
- (void)setZoomFactor:(float)zoomFactor {
	mZoomFactor = zoomFactor / 100.0;
	[self recalculateBounds];
	[self setNeedsDisplay:YES];
}

#pragma mark Misc

- (void)recalculateBoundsAdjustingFrame:(BOOL)adjustFrame
{
	NSArray *pics = [[[NSApp delegate] screenshotsController] arrangedObjects];
	int count = [pics count];

	// NOTE: Incorrectly assume that the user's screen size has not changed. This will be fine for ironcoder.
	CGDirectDisplayID display = CGMainDisplayID();
	int screenWidth = CGDisplayPixelsWide(display);
	int screenHeight = CGDisplayPixelsHigh(display);

	int width = MAX_SCREENSHOT_WIDTH;
	int height = width * screenHeight / screenWidth;
	
	NSSize origSize = NSMakeSize(width, height);
	
	NSRect myRect = [self bounds];
	NSSize mySize = myRect.size;
	mySize.height *= 0.8;

	float downScaleFactor = origSize.height / mySize.height;

	mThumbSize = NSMakeSize((int)(origSize.width / downScaleFactor), mySize.height);
	mThumbSize.width *= mZoomFactor;
	mThumbSize.height *= mZoomFactor;

	if (adjustFrame)
	{
		NSRect newFrame = [self frame];
		newFrame.size.width = (mThumbSize.width + RIGHT_MARGIN) * count;
		if (NSWidth(newFrame) < NSWidth([[self enclosingScrollView] frame]))
			newFrame.size.width = NSWidth([[self enclosingScrollView] frame]) - 2;
		[self setFrame:newFrame];
	}
}

- (void)recalculateBounds
{
	[self recalculateBoundsAdjustingFrame:YES];
}

- (void)setFrame:(NSRect)frame
{
	// We need to redraw ourselves when our frame changes.
	[super setFrame:frame];
	[self recalculateBoundsAdjustingFrame:NO];
	[self setNeedsDisplay:YES];
}

	
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Fill rect with black color
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGColorRef blackColor = CGColorCreate(colorspace, (float[]){0, 0, 0, 1});
	
	CGContextSetFillColorWithColor(ctx, blackColor);

	CGContextFillRect(ctx, NSRectToCGRect(rect));

	// Fill film with dark gray

	CGColorRef darkGrayColor = CGColorCreate(colorspace, (float[]){0.25, 0.25, 0.25, 1});
	CGContextSetFillColorWithColor(ctx, darkGrayColor);

	CGRect filmRect = CGRectMake(rect.origin.x,
								 (NSHeight([self bounds]) - mThumbSize.height * 1.25) / 2,
								 rect.size.width,
								 mThumbSize.height * 1.25);

	CGContextFillRect(ctx, filmRect);

	// Punch black holes on the sides of the film
	CGContextSetFillColorWithColor(ctx, blackColor);
	
	float edgeHeight = mThumbSize.height * 0.125;
	float holeWidth = edgeHeight * 0.5;

	if (holeWidth == 0) return;
	
	int leftHoleIndex = NSMinX(rect) / holeWidth;
	int rightHoleIndex = NSMaxX(rect) / holeWidth;

	float bottomY = filmRect.origin.y + (edgeHeight - holeWidth) / 2;
	float topY = filmRect.origin.y + filmRect.size.height - edgeHeight + (edgeHeight - holeWidth) / 2;
	for (int i = leftHoleIndex; i <= rightHoleIndex; i += 2)
	{
		CGRect holeRect = CGRectMake(i * holeWidth, bottomY, holeWidth, holeWidth);
		CGContextFillRect(ctx, holeRect);
		holeRect = CGRectMake(i * holeWidth, topY, holeWidth, holeWidth);
		CGContextFillRect(ctx, holeRect);
	}
		
	CFRelease(colorspace);
	CFRelease(blackColor);
	CFRelease(darkGrayColor);

	
	// Get the images to draw

	NSArray *pics = [[[NSApp delegate] screenshotsController] arrangedObjects];
	int count = [pics count];
	
	// No images, get the hell out of here
	if (count == 0) return;

	int drawWidth = (mThumbSize.width + RIGHT_MARGIN);
		
	int leftImgIndex = (int)NSMinX(rect) / drawWidth;
	int rightImgIndex = (int)NSMaxX(rect) / drawWidth;

	if (rightImgIndex >= count) rightImgIndex = count-1;

	NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
														[NSNumber numberWithInt:(int)mThumbSize.width], kCGImageSourceThumbnailMaxPixelSize,
												   kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
												   kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageIfAbsent,
												   nil];
	
	// Draw the images
	for (int i = leftImgIndex; i <= rightImgIndex; i++)
	{
		id screenshot = [pics objectAtIndex:i];

		NSData *imageData = [screenshot valueForKey:@"imageData"];
														
		CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
		NSAssert(imageSource != nil, @"we have a NULL image source");

		CGImageRef image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)thumbnailOptions);
		NSAssert(image != nil, @"We got a NULL image here");

		// Finally draw the sucka
		CGRect drawRect = CGRectMake(i * drawWidth,
									 (NSHeight([self bounds]) - mThumbSize.height) / 2,
									 mThumbSize.width,
									 mThumbSize.height);
		CGContextDrawImage(ctx, drawRect, image);
		CFRelease(image);
		CFRelease(imageSource);
	}
}

#pragma mark Mouse Events

- (void)mouseDown:(NSEvent*)event
{
	// Get the point in NSView's coordinates
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];

	// Get the screenshot image under mouse point

	int screenshotIndex = point.x / (mThumbSize.width + RIGHT_MARGIN);

	NSArray *pics = [[[NSApp delegate] screenshotsController] arrangedObjects];
	NSData *imageData = [[pics objectAtIndex:screenshotIndex] valueForKey:@"imageData"];
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
	NSAssert(imageSource != nil, @"we have a NULL image source");

	CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
	NSAssert(image != nil, @"We got a NULL image here");


	[[NSApp delegate] openZoomWindowWithImage:image];

	CFRelease(image);
	CFRelease(imageSource);
}


#pragma mark Printing
- (void)print:(id)sender
{
	NSArray *pics = [[[NSApp delegate] screenshotsController] arrangedObjects];
	TLPrintView *printView = [[TLPrintView alloc] initWithScreenshots:pics];
	
    [[NSPrintOperation printOperationWithView:printView] runOperation];
}

@end
