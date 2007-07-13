//
//  FFM.h
//  FFMinator
//
//  Created by Tom Harrington on 3/4/06;11:04 AM.
//  Copyright 2006 Atomic Bird LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CustomWindow.h"

@interface FFM : NSObject {
    AXUIElementRef			_currentUIElementRef;
    AXUIElementRef			_systemWideElement;
    Point				_lastMousePoint;
	time_t currentUIAppearanceTime;
	BOOL raisedCurrentElement;
	BOOL skipNextRaise;
	
	int focusRaiseDelay;
	
	IBOutlet CustomWindow *toolWindow;
	NSTimer *fadeOutTimer;
	BOOL showMeYourBits;
}
- (void)updateCurrentUIElement:(id)unused;

@end
