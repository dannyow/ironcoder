//
//  BSInvaderView.h
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSInvaderView : NSView {
    float _birthTime;
    NSTimeInterval _birthDuration;
    BOOL _alive;
    
    CIImage *frame1;
    CIImage *frame2;
    CIImage *_currentFrame;
    NSTimer *_frameTimer;
}

- (void)birthAtRect:(NSRect)rect;
- (void)step:(NSRect)rect;

@end
