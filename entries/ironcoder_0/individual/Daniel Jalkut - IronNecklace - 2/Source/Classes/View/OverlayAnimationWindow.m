//
//  OverlayAnimationWindow.m
//
//  Created by Daniel Jalkut on 10/18/05.
//  Copyright 2005 Red Sweater Software. All rights reserved.
//

#import "OverlayAnimationWindow.h"


@implementation OverlayAnimationWindow

+ (id) overlayAnimationWindowForView:(NSView*)inView
{
	OverlayAnimationWindow* newOverlay = [[self class] overlayAnimationWindowWithContentRect:[inView bounds]];
	[newOverlay setContentView:inView];

	// KEEP Retained, allows it to automatically dispose itself only when closed
	return newOverlay;
}

+ (id) overlayAnimationWindowWithContentRect:(NSRect)contentRect
{
	OverlayAnimationWindow* newOverlay = [[[self class] alloc]  initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[newOverlay setOpaque:NO];
	[newOverlay setBackgroundColor:[NSColor clearColor]];
	[newOverlay setIgnoresMouseEvents:YES];

	// KEEP Retained, allows it to automatically dispose itself only when closed
	return newOverlay;
}

- (BOOL)canBecomeKeyWindow
{
	return NO;
}

- (BOOL)canBecomeMainWindow
{
	return NO;
}

@end
