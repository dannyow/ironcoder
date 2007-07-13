//
//  TapDanceController.h
//  TapDance
//
//  Created by Michael Ash on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TapDanceController : NSObject {
	IBOutlet NSArrayController*	mArrayController;
	
	CFMachPortRef				mTapPort;
	
	NSMutableDictionary*		mTimes;
	NSDictionary*				mCurrentApp;
	
	NSTimeInterval				mAccumulatedTime;
	NSTimeInterval				mLastActivityTime;
	
	NSImage*					mStopImage;
	NSImage*					mGoImage;
	
	NSTimer*					mPulseTimer;
	NSTimer*					mBoredomTimer;
}

@end
