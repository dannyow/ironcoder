//
//  DialWindow.m
//  SunMoonDial
//
//  Created by Chris Liscio on 22/07/06.
//  Copyright 2006 SuperMegaUltraGroovy. All rights reserved.
//

#import "DialWindow.h"

@implementation DialWindow

//In Interface Builder we set CustomWindow to be the class for our window, so our own initializer is called here.
// (CL: this function was stolen from Gus' original example)
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    
    //Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
    //for the styleMask so that the window doesn't have a title bar
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    [self setBackgroundColor: [NSColor clearColor]];
    
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    //[self setLevel: NSStatusWindowLevel];
    
    //Let's start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [self setOpaque:NO];
    
    //and while we're at it, make sure the window has a shadow, which will automatically be the shape of our custom content.
    //(CL: this doesn't seem to work on its own, and I still had to turn the "has shadow" property off)
    [self setHasShadow:NO];
    
    [self setIgnoresMouseEvents:YES];
    
    [self setLevel:-2147483628];
    
    return self;
}
@end
