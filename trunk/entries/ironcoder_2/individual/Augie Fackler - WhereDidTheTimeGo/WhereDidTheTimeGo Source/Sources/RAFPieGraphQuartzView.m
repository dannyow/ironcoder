//
//  RAFPieGraphQuartzView.m
//  WhereDidTheTimeGo
//
//  Created by Augie Fackler on 7/22/06.
//  Copyright 2006 R. August Fackler. All rights reserved.
//

#import "RAFPieGraphQuartzView.h"
#import "RAFTimeAppDelegate.h"

#define PI 3.14159265358979323846
#define RADIANS 2*PI

static inline double radians(double degrees) { return degrees * PI / 180; }

@implementation RAFPieGraphQuartzView

- (id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
	return self;
}

- (void)drawRect:(NSRect)rect
{
	int x,y, radius;
	NSSize heightWidth = [self frame].size;
	x = heightWidth.width / 2;
	y = heightWidth.height / 2;
	radius = ((x < y) ? x : y) * 0.8;

	CGRect pageRect;
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	
	pageRect = CGRectMake(0, 0, rect.size.width, rect.size.height);

	CGContextBeginPage(context, &pageRect);

	//  Start with black fill and stroke colors
	CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);

	assert(CGContextIsPathEmpty(context));

	//copy the dictionary so that we don't get bogus stats in case we draw during a sample
	NSDictionary *stats = [(RAFTimeAppDelegate *)[[NSApplication sharedApplication] delegate] getAppStats];
	if (stats) {
		NSDictionary *appStats = [stats copy];
		NSEnumerator *keyEnum = [appStats keyEnumerator];
		NSString *currentAppName;
		unsigned numOfApps = [appStats count]-1;
		unsigned numOfSamples = [[appStats objectForKey:SAMPLE_COUNT_KEY] unsignedIntValue];
		float usedRadians = 0.0;
		float currentHue = 0.0;
		
		CGContextSaveGState(context);
		
		CGContextSetLineWidth(context, 3);
		CGColorSpaceRef rgbSpace =  CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		while ((currentAppName = [keyEnum nextObject])) {
			if (![currentAppName isEqualToString:SAMPLE_COUNT_KEY]) {
				unsigned appSamples = [[appStats objectForKey:currentAppName] unsignedIntValue];
				float sliceRadians = RADIANS*appSamples/numOfSamples;
				NSColor *sliceColor = [NSColor colorWithDeviceHue:currentHue saturation:0.5 brightness:0.7 alpha:1.0];
				currentHue = currentHue + 1.0/numOfApps;
				float components[4];
				sliceColor = [sliceColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
				[sliceColor getComponents:components];

				CGColorRef cgColor = CGColorCreate(rgbSpace,components);
				CGContextSetStrokeColorSpace(context,rgbSpace);
				CGContextSetFillColorSpace(context,rgbSpace);
				CGContextSetFillColorWithColor(context,cgColor);
				CGContextSetStrokeColorWithColor(context,cgColor);
				
				CGMutablePathRef path = CGPathCreateMutable();
				CGPathMoveToPoint(path,NULL,x,y);
				CGPathAddArc(path, NULL, x, y, radius, usedRadians, usedRadians+sliceRadians, 0);

				CGContextAddPath(context,path);
				CGContextFillPath(context);
				CGPathRelease(path);
				
				if (sliceRadians * radius < APP_ICON_SIZE*1.414) {
					path = CGPathCreateMutable();
					CGPathMoveToPoint(path,NULL,x,y);
					float calloutAngle = usedRadians+sliceRadians/2;
					CGPathAddLineToPoint(path,NULL,x+(radius+CALLOUT_LINE_LENGTH)*cosf(calloutAngle),y+(radius+CALLOUT_LINE_LENGTH)*sinf(calloutAngle));
					CGContextAddPath(context,path);
					CGContextStrokePath(context);
					CGPathRelease(path);
				}
				
				CGColorRelease(cgColor);

				usedRadians += sliceRadians;
			}
		}
		
		//do it again for icons
		usedRadians = 0.0;
		keyEnum = [appStats keyEnumerator];
		while ((currentAppName = [keyEnum nextObject])) {
			if (![currentAppName isEqualToString:SAMPLE_COUNT_KEY]) {
				unsigned appSamples = [[appStats objectForKey:currentAppName] unsignedIntValue];
				CGImageRef appIcon;
				NSImage *appImage=[(RAFTimeAppDelegate *)[[NSApplication sharedApplication] delegate] imageForProcessName:currentAppName];
				float sliceRadians = RADIANS*appSamples/numOfSamples;
				usedRadians += sliceRadians;
				if (appImage) {
					appIcon = CGImageRefFromNSImage(appImage);
					float cosAng = cosf(usedRadians-sliceRadians/2);
					float sinAng = sinf(usedRadians-sliceRadians/2);
					float endX = x+radius*cosAng-APP_ICON_SIZE/2.0;
					float endY = y+radius*sinAng-APP_ICON_SIZE/2.0; 
					if (sliceRadians*radius < APP_ICON_SIZE*1.414) {
						endX +=CALLOUT_LINE_LENGTH*cosAng;
						endY +=CALLOUT_LINE_LENGTH*sinAng;
					}

					CGRect targetRect = (CGRect){(CGPoint) {endX, endY},(CGSize){APP_ICON_SIZE,APP_ICON_SIZE}};
					CGContextDrawImage(context,targetRect,appIcon);
					CGImageRelease(appIcon);
				}
				
			}
		}
			
		
		CGColorSpaceRelease(rgbSpace);

		CGContextRestoreGState(context);
	}
	CGContextEndPage(context);
	CGContextFlush(context);
	
	//bla bla, window changes shape, window needs to draw new shadow, silly details
	[[self window] invalidateShadow];
}

//don't use the WebKit function for this because the icons looked ugly when we did that...
CGImageRef CGImageRefFromNSImage(NSImage *image)
{
	NSData* cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [image representations]];
	CFDataRef carbonData = (CFDataRef)cocoaData;
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
	// instead of the NULL above, you can fill a CFDictionary full of options
	// but the default values work for me
	return CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
}

@end
