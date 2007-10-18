//
//  CMotionDetector.h
//  MotionDetector
//
//  Created by Jonathan Wight on 08/18/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>

@interface CMotionDetector : NSObject {
	CIImage *currentImage;
	CIImage *previousImage;
	CIImage *sensorImage;

	CIFilter *differenceFilter;
	
	BOOL calculatingDifferenceRate;
	float differenceRate;
}

- (CIImage *)currentImage;
- (void)setCurrentImage:(CIImage *)inCurrentImage;

- (CIImage *)sensorImage;

- (CIFilter *)weightingFilter;

- (float)differenceRate;
- (void)setDifferenceRate:(float)inDifferenceRate;

@end
