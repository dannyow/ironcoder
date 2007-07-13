//
//  AppDelegate.h
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-22.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject {
	NSMutableArray *processTimers;
}

- (IBAction)runNewTimerWindow:sender;

@end
