//
//  AppDelegate.m
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-22.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import "AppDelegate.h"

#import "ProcessTimer.h"

@implementation AppDelegate

- init {
	if((self = [super init])) {
		processTimers = [[NSMutableArray alloc] initWithCapacity:1U];
	}
	return self;
}
- (void)dealloc {
	[processTimers release];

	[super dealloc];
}

#pragma mark NSApplication delegate conformance

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[self runNewTimerWindow:nil];
}

#pragma mark Notifications

- (void)processTimerDidDie:(NSNotification *)notification {
	[processTimers removeObjectIdenticalTo:[notification object]];
}

#pragma mark Actions

- (IBAction)runNewTimerWindow:sender {
	ProcessTimer *timer = [[ProcessTimer alloc] init];
	[processTimers addObject:timer];
	[timer release];

	[timer setDelegate:self];
	[timer runNewTimerWindow:sender];
}

@end
