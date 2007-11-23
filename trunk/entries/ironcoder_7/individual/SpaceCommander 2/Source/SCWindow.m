//
//  SCWindow.m
//  SpaceCommander
//
//  Created by Zac White on 11/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SCWindow.h"


@implementation SCWindow

- (void)setImage:(NSImage *)image withRotation:(double)rotation{
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,[image size].width, [image size].height)];
	[imageView setImage:image];
	
	[self setContentView:imageView];
	[imageView release];
	
	
/*	//do all the rotation crap.
	NSImage *rotated = [[NSImage alloc] initWithSize:[image size]];
	[rotated lockFocus];
	
	NSAffineTransform *trans = [NSAffineTransform transform];
    //[trans translateXBy:[rotated size].width/2.0 yBy:[rotated size].height/2.0];
	
	[trans rotateByDegrees:rotation];
	//?? whatever.
    //[trans translateXBy:-([baby size].width/4.0) yBy:-([baby size].height/4.0)];
	//apply the affine transform.
    [trans set];
	//draw it at the point.
    [image drawAtPoint:NSMakePoint(0,0) fromRect:NSMakeRect(0, 0, [rotated size].width, [rotated size].height) operation:NSCompositeSourceOver fraction:1.0];
    //unlock focus. probably puts focus back on self.
	[rotated unlockFocus];
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,[image size].width, [image size].height)];
	[imageView setImage:rotated];
	
	[self setContentView:imageView];
	[imageView release];*/
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag{
	//Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
    //for the styleMask so that the window doesn't have a title bar
    if(!(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO]))return nil;
	
    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    //[self setBackgroundColor: [NSColor clearColor]];
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    [self setLevel: NSStatusWindowLevel];
    //Let's start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [self setOpaque:NO];
	[self setBackgroundColor:[NSColor clearColor]];
    //and while we're at it, make sure the window has a shadow, which will automatically be the shape of our custom content.
    [self setHasShadow: YES];
	
    return self;

}

@end
