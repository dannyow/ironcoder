//
//  ETStageView.m
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import "ETStageView.h"


@interface ETStageView(ETStageViewPrivate)

- (void)spotlightImage;
- (void)startNextImageAnimation;

@end


@implementation ETStageView


#define RAD_TO_DEG	57.29577951308232
#define DEG_TO_RAD	.0174532925199432958


- (id)initWithFrame:(NSRect)frame {
	
	if ((self = [super initWithFrame:frame]) != nil) {
		
    	[CIPlugIn loadAllPlugIns];
		
		[self setImageQueue:[NSMutableArray array]];

		[self setSpotlightAnimation:[[[ETSpotlightAnimation alloc] initFrom:[CIVector vectorWithX:NSMidX(frame) Y:NSMidY(frame) Z:100]
																		 to:[CIVector vectorWithX:NSMidX(frame) Y:NSMidY(frame) Z:0]
															  concentration:0.01
																   duration:5.0] autorelease]];
		[[self spotlightAnimation] setColor:[CIColor colorWithRed:0
															green:1
															 blue:0]];
		[[self spotlightAnimation] setBrightness:10.0];
		[[self spotlightAnimation] setDelegate:self];
		[[self spotlightAnimation] startAnimation];
		
		[self setImageAnimation:[[[ETSpotlightAnimation alloc] initFrom:[CIVector vectorWithX:NSMidX([self bounds]) Y:NSMidX([self bounds]) Z:400]
																	 to:[CIVector vectorWithX:NSMidX([self bounds]) Y:NSMidX([self bounds]) Z:0]
														  concentration:0
															   duration:5.0] autorelease]];
		[[self imageAnimation] setDelegate:self];
	}
    
	return self;
}


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self setSpotlightAnimation:nil];
	[self setImageAnimation:nil];
	[self setImageQueue:nil];
	[self setFinalImage:nil];
	
	[super dealloc];
}


#pragma mark Properties


- (NSMutableArray *)imageQueue { return [[_imageQueue retain] autorelease]; }
- (void)setImageQueue:(NSMutableArray *)imageQueue { if (imageQueue != _imageQueue) { [_imageQueue release]; _imageQueue = [imageQueue retain]; } }


- (CIImage *)finalImage { return [[_finalImage retain] autorelease]; }
- (void)setFinalImage:(CIImage *)finalImage { if (finalImage != _finalImage) { [_finalImage release]; _finalImage = [finalImage retain]; } }


- (ETSpotlightAnimation *)spotlightAnimation { return [[_spotlightAnimation retain] autorelease]; }
- (void)setSpotlightAnimation:(ETSpotlightAnimation *)spotlightAnimation { if (spotlightAnimation != _spotlightAnimation) { [_spotlightAnimation release]; _spotlightAnimation = [spotlightAnimation retain]; } }

- (ETSpotlightAnimation *)imageAnimation { return [[_imageAnimation retain] autorelease]; }
- (void)setImageAnimation:(ETSpotlightAnimation *)imageAnimation { if (imageAnimation != _imageAnimation) { [_imageAnimation release]; _imageAnimation = [imageAnimation retain]; } }


#pragma	mark Methods


- (void)queueImage:(NSImage *)image {
			
	[[self imageQueue] addObject:[image toCIImage]];
	
	if (![[self imageAnimation] isAnimating]) {
		
		[self startNextImageAnimation];
	}	
}


- (void)startNextImageAnimation {

	//[[self imageAnimation] stopAnimation];
	
	if ([[self imageQueue] count] > 0) {
		
		[[self imageAnimation] setConcentration:0];		
		[[self imageAnimation] startAnimation];
	}
}


- (void)compositeImage {
	
	const float circleInset = 60;
	
	NSRect clipRect = NSInsetRect([self bounds], circleInset, circleInset);
	
	CIImage *consoleImage = nil;
	{
		CIFilter *gradientFilter = [CIFilter filterWithName:@"CILinearGradient"];
		[gradientFilter setDefaults];
		[gradientFilter setValue:[CIVector vectorWithX:0 Y:0]
						  forKey:@"inputPoint0"];
		[gradientFilter setValue:[CIVector vectorWithX:0 Y:NSMaxY([self bounds])]
						  forKey:@"inputPoint1"];
		[gradientFilter setValue:[CIColor colorWithRed:0.15
												 green:0.15 
												  blue:0.15]
						  forKey:@"inputColor0"];
		[gradientFilter setValue:[CIColor colorWithRed:0
												 green:0 
												  blue:0]
						  forKey:@"inputColor1"];
		consoleImage = [gradientFilter valueForKey:@"outputImage"];
	}
	
	CIImage *gridImage = nil;
	{
		NSImage *image = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
		
		[image lockFocus];
		
		NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:clipRect];		

		[[NSColor blackColor] set];
		[circle fill];
		
		[[NSColor greenColor] set];
		[circle setLineWidth:6];
		[circle stroke];
		
		[circle setLineWidth:1];

		float radius = NSWidth(clipRect) / 2;
		float n = radius / 4;
		int i;
		for (i = 1; i <= 4; i++) {
			
			[[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(clipRect, n*i, n*i)] stroke];
		}

		float angle;
		float length = NSWidth(clipRect) / 2;
		
		for (angle = 0; angle < 360; angle += 360/12) {
						
			NSBezierPath *path = [NSBezierPath bezierPath];
			
			NSPoint from = NSMakePoint(NSMidX([self bounds]), NSMidY([self bounds]));
			NSPoint to   = NSMakePoint(from.x + (length * cos(angle * DEG_TO_RAD)),
									   from.y + (length * sin(angle * DEG_TO_RAD)));
			[path moveToPoint:from];
			[path lineToPoint:to];
			[path stroke];
		}
		
		[image unlockFocus];
		
		gridImage = [image toCIImage];
				
		CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
		[blurFilter setDefaults];
		[blurFilter setValue:gridImage
					  forKey:@"inputImage"];
		[blurFilter setValue:[NSNumber numberWithFloat:1]
					  forKey:@"inputRadius"];
		gridImage = [blurFilter valueForKey:@"outputImage"];
	}
	
	{
		CIFilter *overlayFilter = [CIFilter filterWithName:@"CISourceAtopCompositing"];
		[overlayFilter setDefaults];
		[overlayFilter setValue:gridImage
						 forKey:@"inputImage"];
		[overlayFilter setValue:consoleImage
						 forKey:@"inputBackgroundImage"];
		consoleImage = [overlayFilter valueForKey:@"outputImage"];	
	}
	
	CIImage *compositedImage;

	if ([[self imageQueue] count] > 0) {
		
		CIImage *sourceImage = [[self imageQueue] objectAtIndex:0];
		
		CGRect extent = [sourceImage extent];
		
		float scale = MAX(NSWidth(clipRect)	 / CGRectGetWidth(extent), 
						  NSHeight(clipRect) / CGRectGetHeight(extent));
				
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform translateXBy:((NSWidth([self bounds]) - (CGRectGetWidth(extent) * scale)) / 2)
							yBy:((NSHeight([self bounds]) - (CGRectGetHeight(extent) * scale)) / 2)];
		[transform scaleBy:scale];
		CIFilter *sourceImageTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
		[sourceImageTransformFilter setDefaults];
		[sourceImageTransformFilter setValue:sourceImage
									  forKey:@"inputImage"];
		[sourceImageTransformFilter setValue:transform
									  forKey:@"inputTransform"];
		sourceImage = [sourceImageTransformFilter valueForKey:@"outputImage"];

		compositedImage = [[self imageAnimation] spotlightImage:sourceImage];
		
		CIImage *spotlightImage = [[self spotlightAnimation] spotlightImage:compositedImage];

		CIFilter *spotlightOverlayFilter = [CIFilter filterWithName:@"CISourceAtopCompositing"];
		[spotlightOverlayFilter setDefaults];
		[spotlightOverlayFilter setValue:spotlightImage
								  forKey:@"inputImage"];
		[spotlightOverlayFilter setValue:compositedImage
								  forKey:@"inputBackgroundImage"];
		compositedImage = [spotlightOverlayFilter valueForKey:@"outputImage"];
		
		CIImage *clipImage = nil;
		{
			NSImage *image = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
			[image lockFocus];
			
			NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:clipRect];
			
			[[NSColor blackColor] set];
			[circle fill];
			
			[image unlockFocus];
			clipImage = [image toCIImage];
		}
		
		CIFilter *clipFilter = [CIFilter filterWithName:@"CISourceInCompositing"];
		[clipFilter setDefaults];
		[clipFilter setValue:compositedImage
					  forKey:@"inputImage"];
		[clipFilter setValue:clipImage
					  forKey:@"inputBackgroundImage"];
		compositedImage = [clipFilter valueForKey:@"outputImage"];
		
		CIFilter *overlayFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
		[overlayFilter setDefaults];
		[overlayFilter setValue:compositedImage
						 forKey:@"inputImage"];
		[overlayFilter setValue:consoleImage
						 forKey:@"inputBackgroundImage"];
		compositedImage = [overlayFilter valueForKey:@"outputImage"];
		
	} else {
				
		compositedImage = consoleImage;
	}
		
	[self setFinalImage:compositedImage];
	
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)rect {
		
	if ([self finalImage]) {
		
		[[[NSGraphicsContext currentContext] CIContext] drawImage:[self finalImage]
														  atPoint:CGPointZero
														 fromRect:*(CGRect *)&rect];
	}
}


#pragma mark Animation delegates


- (void)animationDidChange:(ETSpotlightAnimation *)animation {
	
	if ([animation isEqual:[self spotlightAnimation]]) {
		
		float length = MIN(NSWidth([self frame]) / 2, NSHeight([self frame]) / 2);
		float angle = [[self spotlightAnimation] currentProgress] * 360;
				
		[[self spotlightAnimation] setTo:[CIVector vectorWithX:[[[self spotlightAnimation] from] X] + (length * cos(angle * DEG_TO_RAD))
															 Y:[[[self spotlightAnimation] from] Y] + (length * sin(angle * DEG_TO_RAD))
															 Z:[[[self spotlightAnimation] to]   Z]]];
				
	} else if ([animation isEqual:[self imageAnimation]]) {
		
		[[self imageAnimation] setConcentration:0.5];
		[[self imageAnimation] setFromHeight:[[self imageAnimation] currentProgress] * 400];
	}
	
	[self compositeImage];
}


- (void)animationDidEnd:(ETSpotlightAnimation *)animation {
	
	if ([animation isEqual:[self spotlightAnimation]]) {
				
		[[self spotlightAnimation] startAnimation];

	} else if ([animation isEqual:[self imageAnimation]]) {
		
		[[self imageQueue] removeObjectAtIndex:0];
		
		[self startNextImageAnimation];
	}
	
	[self compositeImage];
}


@end