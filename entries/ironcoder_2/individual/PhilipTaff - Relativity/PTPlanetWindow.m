//
//  PTPlanetWindow.m
//  Relativity
//
//  Created by Philip on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PTPlanetWindow.h"
#import "PTPlanetView.h"


@implementation PTPlanetWindow

- (void)awakeFromNib
{
	[self setContentView:[[PTPlanetView alloc] initWithFrame:[self frame]]];
}

#pragma mark NSWindow methods

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	NSRect windowFrame = NSMakeRect(contentRect.origin.x, contentRect.origin.y, PLANET_SIZE, PLANET_SIZE);

	self = [super initWithContentRect:windowFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self == nil)
		return nil;
		
	[self setBackgroundColor:[NSColor clearColor]];
	[self setOpaque:NO];
	
	[self setContentView:[[PTPlanetView alloc] initWithFrame:[self frame]]];

	return self;
}

- (BOOL)isMovableByWindowBackground
{
	return YES;
}

@end
