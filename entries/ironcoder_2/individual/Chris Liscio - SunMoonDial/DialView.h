//
//  DialView.h
//  SunMoonDial
//
//  Created by Chris Liscio on 22/07/06.
//  Copyright 2006 SuperMegaUltraGroovy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DialView : NSView {
    CGImageRef  mImageRef;
    CGImageRef  mMaskRef;
    NSTimer     *mTimer;
    int         mHour;
    int         mMinute;
    float       mRotateDegrees;
}

@end
