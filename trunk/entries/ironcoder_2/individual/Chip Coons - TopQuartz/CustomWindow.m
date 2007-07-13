#import "CustomWindow.h"


@implementation CustomWindow

//In Interface Builder we set CustomWindow to be the class for our window, so our own initializer is called here.
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    
    //Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
    //for the styleMask so that the window doesn't have a title bar
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    [self setBackgroundColor: [NSColor clearColor]];
    
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    [self setLevel: NSStatusWindowLevel];
    
    //Let's start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [self setOpaque:NO];
    
    //and while we're at it, make sure the window has a shadow, which will automatically be the shape of our custom content.
    //[self setHasShadow: NO];
    
    //[self setLevel:-2147483628];
    
    return self;
}

// Custom windows that use the NSBorderlessWindowMask can't become key by default.  Therefore, controls in such windows
// won't ever be enabled by default.  Thus, we override this method to change that.
- (BOOL) canBecomeKeyWindow
{
    return YES;
}


//Once the user starts dragging the mouse, we move the window with it. We do this because the window has no title
//bar for the user to drag (so we have to implement dragging ourselves)
- (void)mouseDragged:(NSEvent *)theEvent
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
}


@end
