//
//  FSBInvisibleWindow.m
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 Henry Skelton. All rights reserved.
//

#import "FSBInvisibleWindow.h"


@implementation FSBInvisibleWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
	self = [super initWithContentRect: contentRect styleMask: NSBorderlessWindowMask backing: bufferingType defer: flag];
	[self setBackgroundColor: [NSColor clearColor]];
    [self setAlphaValue:0.999];
    [self setOpaque:NO];
    [self setHasShadow: YES];
	[self setMovableByWindowBackground:YES];
	return self;
}

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

@end
