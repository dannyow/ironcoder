//
//  OverlayAnimationWindow.h
//
//  Created by Daniel Jalkut on 10/18/05.
//  Copyright 2005 Red Sweater Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OverlayAnimationWindow : NSWindow
{

}

+ (id) overlayAnimationWindowWithContentRect:(NSRect)contentRect;
+ (id) overlayAnimationWindowForView:(NSView*)inView;

@end
