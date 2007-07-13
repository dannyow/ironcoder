//
//  BeadsCentralCore.m
//  Beads
//
//  Created by Peter Hosey on 2006-03-04.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import "BeadsCentralCore.h"

#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <float.h>

#define BEAD_SIZE 28.3464567f /*1 cm in points*/
#define BEAD_SHADOW_OFFSET 1 /*points*/

#define OVERLAY_WINDOW_SIZE { 225.0f, 275.0f }
#define BEAD_SIZE_IN_WINDOW 16.0f /*points*/

#define ZERO_CGPOINT (struct CGPoint){ 0.0f, 0.0f }

static void shadingBlend(void *info, const float *inData, float *outData);

#pragma mark -

@interface BeadsCentralCore (PRIVATE)
- (void)fadeInOverlayWindow;
- (void)fadeOutOverlayWindow;
- (NSImage *)chainOfBeads;
@end

@implementation BeadsCentralCore

- init {
	if((self = [super init])) {
		NSRect frame = { NSZeroPoint, OVERLAY_WINDOW_SIZE };
		panel = [[NSPanel alloc] initWithContentRect:frame
										   styleMask:NSBorderlessWindowMask
											 backing:NSBackingStoreBuffered //Note: Using Retained or Nonretained gets you a black box. Therefore, this must be Buffered.
											   defer:YES];
		[panel setAcceptsMouseMovedEvents:NO];
		[panel setBackgroundColor:[NSColor clearColor]];
		[panel setCanHide:NO];
		[panel setExcludedFromWindowsMenu:YES];
		[panel setFloatingPanel:YES];
		[panel setIgnoresMouseEvents:YES];
		[panel setHasShadow:NO];
		[panel setHidesOnDeactivate:NO];
		[panel setLevel:kCGOverlayWindowLevel];
		[panel setOneShot:YES];
		[panel setOpaque:NO];
		[panel setPreservesContentDuringLiveResize:NO];
		[panel setReleasedWhenClosed:YES];

		NSImageView *imageView = [[NSImageView alloc] initWithFrame:frame];
		[imageView setAutoresizingMask:0];
		[imageView setImageAlignment:NSImageAlignCenter];
		[imageView setImageFrameStyle:NSImageFrameNone];
		[imageView setImageScaling:NSScaleNone];

		[imageView setImage:[self chainOfBeads]];
		[panel setContentView:imageView];
		[imageView release];

		[panel setAlphaValue:0.0f];
		[panel orderFront:nil];

		systemWideUIElement = AXUIElementCreateSystemWide();

		//AX notifications from the system-wide UI element are broken. Instead we must poll with a timer. (Blah.)
		pollingTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1
												 target:self
											   selector:@selector(poll:)
											   userInfo:nil
												repeats:YES] retain];
	}
	return self;
}
- (void)dealloc {
	[panel close];

	[pollingTimer invalidate]; //Also invalidated in -applicationWillTerminate:, but it doesn't hurt to be double-sure.
	[pollingTimer release];

	//See -applicationWillTerminate: for post-app destruction of fadeTimer.

	CFRelease(systemWideUIElement);

	[super dealloc];
}

#pragma mark NSApplication delegate conformance

- (void)applicationWillTerminate:(NSNotification *)notification {
	[pollingTimer invalidate];

	[self fadeOutOverlayWindow];

	//The fade-out uses a timer, so we need to let that run out before we can call the window officially faded out.
	//A side-effect of this is that we are guaranteed that fadeTimer has been invalidated and released, since the fade timer callbacks do that.
	NSDate *oneSecondFromNow = [NSDate dateWithTimeIntervalSinceNow:1.0];
	[[NSRunLoop currentRunLoop] runUntilDate:oneSecondFromNow];
}

#pragma mark PDF data for the beads

- (NSData *)oneBeadWithRed:(float)red green:(float)green blue:(float)blue {
	NSData *result = nil;
	BOOL successful = NO;

	NSMutableData *data = [[NSMutableData alloc] init];

	if(data) {
		CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);

		if(consumer) {
			struct CGRect mediaBox = { ZERO_CGPOINT, { BEAD_SIZE, BEAD_SIZE } };
			CGContextRef pdfContext = CGPDFContextCreate(consumer, &mediaBox, /*auxiliaryInfo*/ NULL);

			if(pdfContext) {
				CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();

				if(rgbColorSpace) {
					const float colorComponents[] = { red, green, blue, /*alpha*/ 1.0f };
					CGColorRef beadColor = CGColorCreate(rgbColorSpace, colorComponents);

					if(beadColor) {
						static const float blackComponents[] = { 0.0f, 0.0f, 0.0f, 0.5f };
						CGColorRef blackColor = CGColorCreate(rgbColorSpace, blackComponents);

						if(blackColor) {
							static const float sheenComponents[] = { 1.0f, 1.0f, 1.0f, 0.6f };
							CGColorRef sheenColor = CGColorCreate(rgbColorSpace, sheenComponents);

							if(sheenColor) {
								CGShadingRef fillShading = NULL;

								struct CGFunctionCallbacks fillFunctionCB = {
															.version = 0U,
															.evaluate = shadingBlend,
															.releaseInfo = NULL //Don't release info (self).
								};
								CGFunctionRef fillFunction = CGFunctionCreate((void *)colorComponents,
																			  //One input component.
																			  /*domainDimension*/ 1U,
																			  /*domain*/ NULL,
																			  //Four output components (RGBA).
																			  /*rangeDimension*/ 4U,
																			  /*range*/ NULL,
																			  &fillFunctionCB);

								if(fillFunction) {
									fillShading = CGShadingCreateAxial(rgbColorSpace,
																	   //Start and end points: horizontally centered, vertically top and bottom respectively.
																	   (struct CGPoint){ 0.5f, 0.0f },
																	   (struct CGPoint){ 0.5f, 1.0f },
																	   fillFunction,
																	   //Do not extend the start or end.
																	   /*extendStart*/ false,
																	   /*extendEnd*/ false);

									CFRelease(fillFunction);
								}

								CGContextBeginPage(pdfContext, /*mediaBox*/ NULL);

								CGContextScaleCTM(pdfContext, BEAD_SIZE, BEAD_SIZE);

								//Fill the bead.
								CGContextSaveGState(pdfContext);
								CGContextAddArc(pdfContext,
												//Center point: dead center.
												0.5f, 0.5f,
												//Radius: the radius of our bead.
												0.5f,
												//Arc length: completely around.
												/*startAngle*/ 0.0f,
												/*endAngle*/   M_PI * 2.0f,
												//Clockwise: no.
												false);
								CGContextClip(pdfContext);
								CGContextSetFillColorWithColor(pdfContext, beadColor);
								if(fillShading)
									CGContextDrawShading(pdfContext, fillShading);
								else
									CGContextFillRect(pdfContext, (struct CGRect){ ZERO_CGPOINT, mediaBox.size });
								CGContextRestoreGState(pdfContext);

								//Draw a sheen on the bead, using two Bézier curves. We move counter-clockwise, of course.
								CGContextMoveToPoint(pdfContext, 0.9f, 0.6f);
								//Top curve.
								CGContextAddQuadCurveToPoint(pdfContext, 0.5f, 1.0f, 0.1f, 0.6f);
								//Bottom curve.
								CGContextAddQuadCurveToPoint(pdfContext, 0.5f, 0.77f, 0.9f, 0.6f);
								CGContextClosePath(pdfContext);
								CGContextSetFillColorWithColor(pdfContext, sheenColor);
								CGContextFillPath(pdfContext);

								//Draw a black outline on the bead.
								CGContextSetLineWidth(pdfContext, 3.0f);
								CGContextSetStrokeColorWithColor(pdfContext, blackColor);
								CGContextStrokeEllipseInRect(pdfContext, mediaBox);

								CGContextEndPage(pdfContext);
								successful = YES;

								if(fillShading)
									CFRelease(fillShading);

								CFRelease(sheenColor);
							}

							CFRelease(blackColor);
						}

						CFRelease(beadColor);
					}

					CFRelease(rgbColorSpace);
				}

				CFRelease(pdfContext);
			}

			CFRelease(consumer);
		}

		//Replace our mutable data with immutable data.
		if(successful)
			result = [NSData dataWithData:data];

		[data release];
	}

	return result;
}

- (NSData *)redBeadData {
	return [self oneBeadWithRed:1.0f green:0.0f blue:0.0f];
}
- (NSData *)greenBeadData {
	return [self oneBeadWithRed:0.0f green:1.0f blue:0.0f];
}
- (NSData *)blueBeadData {
	return [self oneBeadWithRed:0.0f green:0.0f blue:1.0f];
}
- (NSData *)goldBeadData {
	return [self oneBeadWithRed:1.0f green:0.9f blue:0.0f];
}
- (NSData *)purpleBeadData {
	return [self oneBeadWithRed:1.0f green:0.0f blue:1.0f];
}

- (NSData *)beadShadowData {
	NSData *result = nil;
	BOOL successful = NO;

	NSMutableData *data = [[NSMutableData alloc] init];

	if(data) {
		CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);

		if(consumer) {
			struct CGRect mediaBox = { ZERO_CGPOINT, { BEAD_SIZE, BEAD_SIZE } };
			CGContextRef pdfContext = CGPDFContextCreate(consumer, &mediaBox, /*auxiliaryInfo*/ NULL);

			if(pdfContext) {
				CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();

				if(grayColorSpace) {
					static const float blackComponents[] = { 0.0f, 0.8f };
					CGColorRef blackColor = CGColorCreate(grayColorSpace, blackComponents);
					
					if(blackColor) {
						CGContextBeginPage(pdfContext, /*mediaBox*/ NULL);

						struct CGRect shadowRect = mediaBox;
						CGContextSetFillColorWithColor(pdfContext, blackColor);
						CGContextFillEllipseInRect(pdfContext, shadowRect);

						CGContextEndPage(pdfContext);
						successful = YES;

						CFRelease(blackColor);
					}

					CFRelease(grayColorSpace);
				}

				CFRelease(pdfContext);
			}

			CFRelease(consumer);
		}

		//Replace our mutable data with immutable data.
		if(successful)
			result = [NSData dataWithData:data];

		[data release];
	}

	return result;
}

#pragma mark Setting the location of the window

//pt should be the top-left corner of the window.
- (void)moveBeadsToPoint:(NSPoint)pt {
	//NSWindow coordinates are from the bottom-left of the main screen. We must invert pt accordingly to move our window.
	NSScreen *mainScreen = [NSScreen mainScreen];

	NSRect frame = [panel frame];
	NSPoint currentOrigin = frame.origin;

	frame.origin.x = (pt.x - BEAD_SIZE_IN_WINDOW) - 1.0f;
	frame.origin.y = (([mainScreen frame].size.height - (pt.y - BEAD_SIZE_IN_WINDOW)) - frame.size.height) + 1.0f;

	//This picks up a savings of about 0.05% CPU on my Cube.
	if(!NSEqualPoints(currentOrigin, frame.origin))
		[panel setFrame:frame display:YES animate:YES];
}

#pragma mark Polling timer callback

- (void)poll:(NSTimer *)timer {
	AXUIElementRef element = NULL;
	AXUIElementCopyAttributeValue(systemWideUIElement, kAXFocusedApplicationAttribute, (CFTypeRef *)&element);

	if(!element) {
		//If there is no focused application…
		[self fadeOutOverlayWindow];
	} else {
		AXUIElementRef window = NULL;
		AXUIElementCopyAttributeValue(element, kAXFocusedWindowAttribute, (CFTypeRef *)&window);

		if(!window)
			[self fadeOutOverlayWindow];
		else {
			//Start a fade-in (if necessary) and reposition the beads to that point.
			NSPoint origin = NSZeroPoint;
			AXValueRef originValue = NULL;
			AXUIElementCopyAttributeValue(window, kAXPositionAttribute, (CFTypeRef *)&originValue);

			if(originValue)
				AXValueGetValue(originValue, kAXValueCGPointType, (struct CGPoint *)&origin);

			[self fadeInOverlayWindow];

			[self moveBeadsToPoint:origin];

			CFRelease(window);
		}

		CFRelease(element);
	}
}

#pragma mark Window-fade timer callbacks

- (void)fadeInOverlayWindow:(NSTimer *)timer {
	float alpha = [panel alphaValue];
	if((1.0f - alpha) < FLT_EPSILON) {
		//This is the last step. Invalidate and free the timer.
		[fadeTimer invalidate];
		[fadeTimer release];
		fadeTimer = nil;
		isFadingIn = NO;
	} else {
		if(alpha < FLT_EPSILON) {
			//This is the first step. Order the window in first.
			[panel orderFront:nil];
		}

		alpha = fabsf(alpha) + 0.1f;
		[panel setAlphaValue:alpha];
	}
}

- (void)fadeOutOverlayWindow:(NSTimer *)timer {
	float alpha = [panel alphaValue];
	if(alpha < FLT_EPSILON) {
		//This is the larst step. Order the window out, then invalidate and free the timer.
		[panel orderOut:nil];
		[fadeTimer invalidate];
		[fadeTimer release];
		fadeTimer = nil;
		isFadingOut = NO;
	} else {
		alpha -= 0.1f;
		[panel setAlphaValue:alpha];
	}
}

@end

@implementation BeadsCentralCore (PRIVATE)

- (void)fadeInOverlayWindow {
	if(([panel alphaValue] < FLT_EPSILON) && !isFadingIn) {
		//Fade it in.
		[fadeTimer invalidate];
		[fadeTimer release];
		fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05
													  target:self
													selector:@selector(fadeInOverlayWindow:)
													userInfo:nil
													 repeats:YES] retain];
		isFadingIn = YES;
		isFadingOut = NO;
	}
}
- (void)fadeOutOverlayWindow {
	if(([panel alphaValue] > FLT_EPSILON) && !isFadingOut) {
		//Fade it out.
		[fadeTimer invalidate];
		[fadeTimer release];
		fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05
													  target:self
													selector:@selector(fadeOutOverlayWindow:)
													userInfo:nil
													 repeats:YES] retain];
		isFadingOut = YES;
		isFadingIn = NO;
	}
}

- (NSImage *)chainOfBeads {
	union {
		struct CGSize quartz;
		NSSize appKit;
	} size = { .appKit = OVERLAY_WINDOW_SIZE };

	CGPDFDocumentRef beads[5] = { NULL, NULL, NULL, NULL, NULL };
	CGPDFDocumentRef beadShadow = NULL;
	CGDataProviderRef provider;

	provider = CGDataProviderCreateWithCFData((CFDataRef)[self redBeadData]);
	if(provider) {
		beads[0] = CGPDFDocumentCreateWithProvider(provider);
		CFRelease(provider);
	}
	provider = CGDataProviderCreateWithCFData((CFDataRef)[self greenBeadData]);
	if(provider) {
		beads[1] = CGPDFDocumentCreateWithProvider(provider);
		CFRelease(provider);
	}
	provider = CGDataProviderCreateWithCFData((CFDataRef)[self blueBeadData]);
	if(provider) {
		beads[2] = CGPDFDocumentCreateWithProvider(provider);
		CFRelease(provider);
	}
	provider = CGDataProviderCreateWithCFData((CFDataRef)[self goldBeadData]);
	if(provider) {
		beads[3] = CGPDFDocumentCreateWithProvider(provider);
		CFRelease(provider);
	}
	provider = CGDataProviderCreateWithCFData((CFDataRef)[self purpleBeadData]);
	if(provider) {
		beads[4] = CGPDFDocumentCreateWithProvider(provider);
		CFRelease(provider);
	}
	provider = CGDataProviderCreateWithCFData((CFDataRef)[self beadShadowData]);
	if(provider) {
		beadShadow = CGPDFDocumentCreateWithProvider(provider);
		CFRelease(provider);
	}

	NSMutableData *chainData = [[NSMutableData alloc] init];
	
	if(chainData) {
		CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)chainData);
		
		if(consumer) {
			struct CGRect mediaBox = { ZERO_CGPOINT, size.quartz };
			CGContextRef pdfContext = CGPDFContextCreate(consumer, &mediaBox, /*auxiliaryInfo*/ NULL);

			if(pdfContext) {
				CGContextBeginPage(pdfContext, &mediaBox);

				struct CGRect destRect = { { 16.0f, size.quartz.height - BEAD_SIZE_IN_WINDOW }, { BEAD_SIZE_IN_WINDOW, BEAD_SIZE_IN_WINDOW } };
				struct CGRect shadowDestRect = destRect;
				shadowDestRect.origin.x += BEAD_SHADOW_OFFSET;
				shadowDestRect.origin.y -= BEAD_SHADOW_OFFSET;
				float beadOffset = BEAD_SIZE_IN_WINDOW + 8.0f;

				srandom(time(NULL));

				//We draw the shadow, then the bead, so that the bead is on top.
#define DRAW_BEAD(memberToChange, beadOffset)                                        \
				CGContextDrawPDFDocument(pdfContext, shadowDestRect, beadShadow, 1);  \
				shadowDestRect.origin.memberToChange += (beadOffset);                  \
				CGContextDrawPDFDocument(pdfContext, destRect, beads[random() % 5], 1); \
				destRect.origin.memberToChange += (beadOffset)
				//Nine beads in a row at the top. These will rest on the title bar.
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);
				DRAW_BEAD(x, beadOffset);

				destRect.origin = (struct CGPoint){ 0.0f, mediaBox.size.height - BEAD_SIZE_IN_WINDOW * 2.0f };
				shadowDestRect.origin = destRect.origin;
				shadowDestRect.origin.x += BEAD_SHADOW_OFFSET;
				shadowDestRect.origin.y -= BEAD_SHADOW_OFFSET;

				//Eleven beads in a column on the left. These are draped down the left side of the window.
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				DRAW_BEAD(y, -beadOffset);
				
				//Finally, the curve between these points. This is the part that hangs down between the draped left line and the resting top line.
#define DRAW_BEAD_AT_POINT(xCoordinate, yCoordinate)                                                              \
				shadowDestRect.origin = (struct CGPoint){ xCoordinate, yCoordinate };                              \
				CGContextDrawPDFDocument(pdfContext, shadowDestRect, beadShadow, 1);                                \
				destRect.origin = (struct CGPoint){ shadowDestRect.origin.x - 1.0f, shadowDestRect.origin.y + 1.0f}; \
				CGContextDrawPDFDocument(pdfContext, destRect, beads[random() % 5], 1)
				DRAW_BEAD_AT_POINT(207.0f, 237.0f);
				DRAW_BEAD_AT_POINT(204.0f, 215.0f);
				DRAW_BEAD_AT_POINT(201.0f, 195.0f);
				DRAW_BEAD_AT_POINT(196.0f, 174.0f);
				DRAW_BEAD_AT_POINT(189.0f, 156.0f);
				DRAW_BEAD_AT_POINT(181.0f, 138.0f);
				DRAW_BEAD_AT_POINT(170.0f, 119.0f);
				DRAW_BEAD_AT_POINT(159.0f, 101.0f);
				DRAW_BEAD_AT_POINT(147.0f,  83.0f);
				DRAW_BEAD_AT_POINT(133.0f,  67.0f);
				DRAW_BEAD_AT_POINT(117.0f,  53.0f);
				DRAW_BEAD_AT_POINT(101.0f,  41.0f);
				DRAW_BEAD_AT_POINT( 81.0f,  27.0f);
				DRAW_BEAD_AT_POINT( 61.0f,  17.0f);
				DRAW_BEAD_AT_POINT( 42.0f,  10.0f);
				DRAW_BEAD_AT_POINT( 22.0f,   6.0f);

#undef DRAW_BEAD
#undef DRAW_BEAD_AT_POINT

				CGContextEndPage(pdfContext);

				CFRelease(pdfContext);
			}

			CFRelease(consumer);
		}
	}

	NSImage *image = [[[NSImage alloc] initWithData:chainData] autorelease];
	[chainData release];
	return image;
}

@end

#pragma mark -
#pragma mark Drawing

static void shadingBlend(void *info, const float *inData, float *outData) {
	//This sine curve is used to brighten the bead near the top and darken it near the bottom.
	const float saturationDelta = sinf((inData[0] - 0.5f) * M_PI) * 0.5f;

	const float *colorComponents = info;
	//R, G, B…
	outData[0] = colorComponents[0] + saturationDelta;
	outData[1] = colorComponents[1] + saturationDelta;
	outData[2] = colorComponents[2] + saturationDelta;

	//and A.
	outData[3] = 1.0f;
}
