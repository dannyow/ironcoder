//
//  HarnessController.h
//  TestScreenSaver
//
//  Created by Ben Gottlieb on 3/31/07.
//  Copyright 2007 Stand Alone, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaverView.h>
#import "SaverView.h"

@interface HarnessController : NSObject {
	IBOutlet WikiPathScreenSaver_SaverView		*view;
	IBOutlet NSWindow							*window;
	
	NSTimer										*timer;
}


- (void) timerFired: (NSTimer *) timer;
- (IBAction) configure: (id) sender;

@end
