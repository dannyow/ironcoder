//
//  CSequenceGrabberVideoChannel.h
//  SequenceGrabber
//
//  Created by Jonathan Wight on 08/06/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CSequenceGrabberChannel.h"

@class CSequenceGrabber;
@class CDecompressionSession;
@class CCarbonGWorld;

@interface CSequenceGrabberVideoChannel : CSequenceGrabberChannel {
	CCarbonGWorld *offscreenGWorld;
	CDecompressionSession *decompressionSession;
	CVImageBufferRef imageBuffer;
}

- (CDecompressionSession *)decompressionSession;

- (float)frameRate;
- (void)setFrameRate:(float)inFrameRate;

- (NSSize)size;
- (void)setSize:(NSSize)inSize;

- (CVImageBufferRef)imageBuffer;

@end

#pragma mark -

extern NSString *kSequenceGrabberVideoChannelDidReceiveImageBufferNotification /* = @"kSequenceGrabberVideoChannelDidReceiveImageBufferNotification" */;
