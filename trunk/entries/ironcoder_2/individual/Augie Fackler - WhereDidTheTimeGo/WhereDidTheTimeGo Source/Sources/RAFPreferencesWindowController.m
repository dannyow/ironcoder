//
//  RAFPreferencesWindowController.m
//  WhereDidTheTimeGo
//
//  Created by Augie Fackler on 7/23/06.
//  Copyright 2006 R. August Fackler. All rights reserved.
//

#import "RAFPreferencesWindowController.h"
#import "RAFTimeAppDelegate.h"

@implementation RAFPreferencesWindowController

RAFPreferencesWindowController *sharedController = nil;

+ (RAFPreferencesWindowController *)showPreferences
{
	if (!sharedController)
		sharedController = [[RAFPreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
	[[sharedController window] makeKeyAndOrderFront:nil];
	return sharedController;
}

- (IBAction)resetPrefs:(id)sender
{
	[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:self];
}

- (IBAction)resetStats:(id)sender;
{
	[(RAFTimeAppDelegate *)[[NSApplication sharedApplication] delegate] resetAppStats];
}

@end
