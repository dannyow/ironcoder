//
//  RAFDesktopWindow.m
//  WhereDidTheTimeGo
//
//  Created by Augie Fackler on 7/22/06.
//  Copyright 2006 R. August Fackler. All rights reserved.
//

#import "RAFDesktopWindow.h"


@implementation RAFDesktopWindow

//NSRect screenFrame = [[NSScreen mainScreen]frame];
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    //Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
    //for the styleMask so that the window doesn't have a title bar
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

    [self setLevel:kCGDesktopWindowLevel];
    
	[self setBackgroundColor: [NSColor clearColor]];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setIgnoresMouseEvents:YES];
    [self setHasShadow:YES];
    return self;
}

#pragma mark Window Dragging - unused
/*- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint currentLocation;
	NSPoint newOrigin;
	NSRect  screenFrame = [[NSScreen mainScreen] frame];
	NSRect  windowFrame = [self frame];
	
	
	//grab the current global mouse location; we could just as easily get the mouse location 
	//in the same way as we do in -mouseDown:
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
		newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [self setFrameOrigin:newOrigin];
}

//We start tracking the a drag operation here when the user first clicks the mouse,
//to establish the initial location.

- (void)mouseDown:(NSEvent *)theEvent
{    
    NSRect  windowFrame = [self frame];
	
    //grab the mouse location in global coordinates
	initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	initialLocation.x -= windowFrame.origin.x;
	initialLocation.y -= windowFrame.origin.y;
}*/

@end
