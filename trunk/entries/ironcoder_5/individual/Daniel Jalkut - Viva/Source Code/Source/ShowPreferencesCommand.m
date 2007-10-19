//
//  ShowPreferencesCommand.m
//  VivaApp
//
//  Created by Daniel Jalkut on 4/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ShowPreferencesCommand.h"
#import "VivaAppDelegate.h"

@implementation ShowPreferencesCommand

- (id) performDefaultImplementation
{
	[[NSApp delegate] showPreferencesDialog:self];
	return nil;
}

@end
