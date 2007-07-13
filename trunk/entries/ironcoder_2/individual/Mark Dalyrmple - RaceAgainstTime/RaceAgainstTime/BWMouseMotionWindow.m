#import "BWMouseMotionWindow.h"

@implementation BWMouseMotionWindow

// We get a mouse motion event.  Send it on to the motion target.

- (void) mouseMoved: (NSEvent *) event
{
    [motionTarget mouseMoved: event];

} // mouseMoved



// Set the victim that will get the motion events.

- (void) setMotionTarget: (NSView *) view
{
    motionTarget = view;

} // setMotionTarget



@end // BWMouseMotionWindow

