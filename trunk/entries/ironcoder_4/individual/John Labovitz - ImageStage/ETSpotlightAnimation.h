//
//  ETSpotlightAnimation.h
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface ETSpotlightAnimation : NSAnimation {
	
	CIVector *_from;
	CIVector *_to;
	float _concentration;
	float _brightness;
	CIColor *_color;
}

- (id)initFrom:(CIVector *)from
			to:(CIVector *)to
 concentration:(float)concentration
	  duration:(NSTimeInterval)duration;

- (CIVector *)from;
- (void)setFrom:(CIVector *)from;

- (CIVector *)to;
- (void)setTo:(CIVector *)to;

- (float)concentration;
- (void)setConcentration:(float)concentration;

- (CIColor *)color;
- (void)setColor:(CIColor *)color;

- (float)brightness;
- (void)setBrightness:(float)brightness;

- (CIImage *)spotlightImage:(CIImage *)image;

- (float)fromHeight;
- (void)setFromHeight:(float)height;

- (float)toHeight;
- (void)setToHeight:(float)height;

@end