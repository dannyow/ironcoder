//
//  CMyController.h
//  MotionDetector
//
//  Created by Jonathan Wight on 10/19/2004.
//  Copyright 2004 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSequenceGrabber;
@class CMotionDetector;
@class CCoreImageView;

@interface CMyController : NSObject {
	IBOutlet NSWindow *outletWindow;

	IBOutlet CCoreImageView *outletInputVideoView;

	CSequenceGrabber *sequenceGrabber;
	CMotionDetector *motionDetector;
}

@end
