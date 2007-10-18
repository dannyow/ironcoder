//
//  BSInvaderBackgroundWindow.m
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSInvaderBackgroundWindow.h"

@implementation BSInvaderBackgroundWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	
    NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [result setBackgroundColor: [NSColor clearColor]];
    [result setLevel:NSNormalWindowLevel];
    [result setHasShadow:NO];
    [result setAlphaValue:1.0];

    return result;
}

- (void)awakeFromNib
{
    [self setFrame:[[NSScreen mainScreen] frame] display:YES];
}

@end
