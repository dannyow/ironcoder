//
//  ETStageView.h
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "ETSpotlightAnimation.h"
#import "ETCIImageAdditions.h"
#import "ETNSImageAdditions.h"

@interface ETStageView : NSView {

	NSMutableArray *_imageQueue;
	CIImage *_finalImage;
	ETSpotlightAnimation *_spotlightAnimation;
	ETSpotlightAnimation *_imageAnimation;
}

- (void)queueImage:(NSImage *)image;

- (NSMutableArray *)imageQueue;
- (void)setImageQueue:(NSMutableArray *)imageQueue;

- (CIImage *)finalImage;
- (void)setFinalImage:(CIImage *)finalImage;

- (ETSpotlightAnimation *)spotlightAnimation;
- (void)setSpotlightAnimation:(ETSpotlightAnimation *)spotlightAnimation;

- (ETSpotlightAnimation *)imageAnimation;
- (void)setImageAnimation:(ETSpotlightAnimation *)imageAnimation;

@end