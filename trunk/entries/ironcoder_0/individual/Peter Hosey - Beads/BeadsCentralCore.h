//
//  BeadsCentralCore.h
//  Beads
//
//  Created by Peter Hosey on 2006-03-04.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

@interface BeadsCentralCore : NSObject {
	NSPanel *panel;
	NSTimer *pollingTimer, *fadeTimer;
	AXUIElementRef systemWideUIElement;
	unsigned reserved: 30;
	unsigned isFadingIn: 1;
	unsigned isFadingOut: 1;
}

@end
