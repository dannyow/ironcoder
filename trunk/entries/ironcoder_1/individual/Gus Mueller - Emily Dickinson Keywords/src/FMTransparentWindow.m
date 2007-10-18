//
//  FMTransparentWindow.m
//  fmkit
//
//  Created by August Mueller on 1/26/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import "FMTransparentWindow.h"


@implementation FMTransparentWindow

- (id) xinitWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    
    //self = [super initWithContentRect:contentRect styleMask: NSClosableWindowMask | NSMiniaturizableWindowMask | NSTitledWindowMask | NSUtilityWindowMask | NSNonactivatingPanelMask backing:bufferingType defer:flag];
    self = [super initWithContentRect:contentRect styleMask: NSBorderlessWindowMask backing:bufferingType defer:flag];
    
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setMovableByWindowBackground:YES];
    [self setAcceptsMouseMovedEvents:YES];
    
    return self;
}

- (BOOL) canBecomeKeyWindow {
    return YES;
}


@end
