//
//  DaliWindow.m
//  DaliClock
//
//  Created by Kevin Ballard on 7/23/06.
//  Copyright 2006 Tildesoft. All rights reserved.
//

#import "DaliWindow.h"


@implementation DaliWindow

- (BOOL)canBecomeMainWindow {
	return YES;
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (void)performClose:(id)sender {
	[self close];
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem {
	if ([menuItem action] == @selector(performClose:)) {
		return YES;
	} else {
		return [super validateMenuItem:menuItem];
	}
}

@end
