#import "JTWindow.h"

@implementation JTWindow

//In Interface Builder we set JTSplashWindow to be the class for our window, so our own initializer is called here.
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
	NSRect theScreenRect = [[NSScreen mainScreen] frame];

    //Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
    //for the styleMask so that the window doesn't have a title bar
    NSWindow* result = [super initWithContentRect:theScreenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    [result setBackgroundColor: [NSColor clearColor]];

    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
	[result setLevel:NSTornOffMenuWindowLevel];

    //Let's start with no transparency for all drawing into the window
    [result setAlphaValue:1.0];

    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [result setOpaque:NO];

    //and while we're at it, make sure the window has a shadow, which will automatically be the shape of our custom content.
    [result setHasShadow:NO];
	
	[result setAcceptsMouseMovedEvents:YES];

    return( result );
}

@end
