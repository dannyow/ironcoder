//
//  ETSpotlightAnimation.m
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import "ETSpotlightAnimation.h"


@implementation ETSpotlightAnimation


- (id)initFrom:(CIVector *)from
			to:(CIVector *)to
 concentration:(float)concentration
	  duration:(NSTimeInterval)duration {
	
	if ((self = [super initWithDuration:duration
						 animationCurve:NSAnimationEaseIn]) != nil) {

		[self setFrom:from];
		[self setTo:to];
		[self setConcentration:concentration];
		[self setAnimationBlockingMode:NSAnimationNonblocking];
		[self setFrameRate:60.0];
		
		[self setBrightness:3.0];	//FIXME: Should get from default?
	}
	
	return self;
}


- (NSString *)description {
	
	return [NSString stringWithFormat:@"%@, from = %@, to = %@, concentration = %f", [super description], [self from], [self to], [self concentration]];
}


#pragma mark Properties


- (CIVector *)from { return [[_from retain] autorelease]; }
- (void)setFrom:(CIVector *)from { if (from != _from) { [_from release]; _from = [from retain]; } }

- (CIVector *)to { return [[_to retain] autorelease]; }
- (void)setTo:(CIVector *)to { if (to != _to) { [_to release]; _to = [to retain]; } }

- (float)concentration { return _concentration; }
- (void)setConcentration:(float)concentration { _concentration = concentration; }

- (CIColor *)color { return [[_color retain] autorelease]; }
- (void)setColor:(CIColor *)color { if (color != _color) { [_color release]; _color = [color retain]; } }

- (float)brightness { return _brightness; }
- (void)setBrightness:(float)brightness { _brightness = brightness; }


- (float)fromHeight { return [_from Z]; }
- (void)setFromHeight:(float)height { [self setFrom:[CIVector vectorWithX:[_from X] Y:[_from Y] Z:height]]; }

- (float)toHeight { return [_to Z]; }
- (void)setToHeight:(float)height { [self setTo:[CIVector vectorWithX:[_to X] Y:[_to Y] Z:height]]; }


#pragma mark Methods


- (CIImage *)spotlightImage:(CIImage *)image {
		
	CIFilter *spotlightFilter = [CIFilter filterWithName:@"CISpotLight"];
	[spotlightFilter setDefaults];
	
	[spotlightFilter setValue:image
					   forKey:@"inputImage"];
	[spotlightFilter setValue:[self from]
					   forKey:@"inputLightPosition"];
	[spotlightFilter setValue:[self to]
					   forKey:@"inputLightPointsAt"];
	[spotlightFilter setValue:[NSNumber numberWithFloat:[self concentration]]
					   forKey:@"inputConcentration"];
	[spotlightFilter setValue:[NSNumber numberWithFloat:[self brightness]]
					   forKey:@"inputBrightness"];

	if ([self color]) {
		
		[spotlightFilter setValue:[self color]
						   forKey:@"inputColor"];
	}
	
	return [spotlightFilter valueForKey:@"outputImage"];
}


- (void)setCurrentProgress:(NSAnimationProgress)progress {
	
    [super setCurrentProgress:progress];
		
	[[self delegate] performSelector:@selector(animationDidChange:)
						  withObject:self];
}


@end