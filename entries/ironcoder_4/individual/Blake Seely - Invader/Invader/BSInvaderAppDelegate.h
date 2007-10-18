//
//  BSInvaderAppDelegate.h
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSInvaderAppDelegate : NSObject {
    IBOutlet NSWindow *window;
    IBOutlet NSView *invaderView;
    
    NSMutableSet *_liveInvaders;
    
    int _stepCount;
    BOOL _stepDirection;
    NSTimer *_stepTimer;
}

@end
