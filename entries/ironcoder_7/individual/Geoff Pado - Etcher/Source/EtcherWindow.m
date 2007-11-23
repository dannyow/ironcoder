//
//  EtcherWindow.m
//  Etcher
//
//  Created by Geoff Pado on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "EtcherWindow.h"


@implementation EtcherWindow

- (NSWindow *)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask backing:(NSBackingStoreType)backing defer:(BOOL)deferred
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backing defer:NO];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

@end
