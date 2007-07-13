//
//  Mugshot
//
//  Created by Blake Seely on 12/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUBorderlessTransparentWindow.h"


@implementation MUBorderlessTransparentWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	
    NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [result setBackgroundColor: [NSColor clearColor]];
    [result setAlphaValue:1.0];
    [result setOpaque:NO];
    [result setHasShadow: YES];
    [result setLevel:NSScreenSaverWindowLevel];
        
    return result;
}
- (BOOL) canBecomeKeyWindow
{
    return YES;
}

@end
