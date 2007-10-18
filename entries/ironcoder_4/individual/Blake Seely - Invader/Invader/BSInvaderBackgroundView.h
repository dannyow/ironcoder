//
//  BSInvaderBackgroundView.h
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BSInvaderAppDelegate;

@interface BSInvaderBackgroundView : NSView {
    BSInvaderAppDelegate *delegate;
    
    CIImage *_backgroundImage;
    
    NSMutableSet *_bullets;
    NSTimer *_bulletTimer;
}


@end
