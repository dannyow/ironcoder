//
//  TLScreenshotTaker.h
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TLScreenshotGrabber : NSObject {
	UInt32 *mImageBuffer;
}

+ (TLScreenshotGrabber*)grabber;
- (NSData*)screenshotImageData;

@end
