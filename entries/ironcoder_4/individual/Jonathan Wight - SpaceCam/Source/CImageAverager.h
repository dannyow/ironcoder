//
//  CImageAverager.h
//  Space
//
//  Created by Jonathan Wight on 10/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CIFilter;

@interface CImageAverager : NSObject {
	CIImage *averageImage;
	unsigned count;
	CIFilter *weightingFilter;
}

- (CIImage *)averageImage;
- (void)setAverageImage:(CIImage *)inAverageImage;

- (unsigned)count;
- (void)setCount:(unsigned)inCount;

- (void)addImage:(CIImage *)inImage;

- (CIFilter *)weightingFilter;

@end
