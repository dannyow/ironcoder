//
//  ConfigPanel.m
//  TwitterLife
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "ConfigPanel.h"
#import <ScreenSaver/ScreenSaver.h>

@implementation ConfigPanel

static NSString * const mySaver = @"com.matthewcrandall.TwitterLife";

-(id) init {
	
	self = [super init];
	if (self) {
		[NSBundle loadNibNamed:@"Config" owner:self];
	}
	
	return self;
}

- (NSPanel *)panel {
	return _panel;
}

- (void) awakeFromNib {

	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:mySaver];

	[_updates selectItemWithTag:[defaults integerForKey:@"updates"]];
	[_dataset selectItemWithTag:[defaults integerForKey:@"dataset"]];
	[_username setStringValue:[defaults stringForKey:@"username"]];
	[_password setStringValue:[defaults stringForKey:@"password"]];
}

- (IBAction)cancelClick:(id)sender {
	ScreenSaverDefaults *defaults;

	defaults = [ScreenSaverDefaults defaultsForModuleWithName:mySaver];
			
	// Update our defaults
	[defaults setInteger:[_updates selectedTag] forKey:@"updates"]; 
	[defaults setInteger:[_dataset selectedTag] forKey:@"dataset"];
	[defaults setValue:[_username stringValue] forKey:@"username"];
	[defaults setValue:[_password stringValue] forKey:@"password"];
	
	// Save the settings to disk
	[defaults synchronize];

	[[NSApplication sharedApplication] endSheet:_panel];
}

@end
