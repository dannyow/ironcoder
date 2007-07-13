// BWMouseMotionWindow.h -- window subclass to make mouse motion events not
// 			    suck.
// The problems I was having was the occasional infinite loop, plus
// sometimes it's not convienient to be first responder to get the 
// events.

#import <Cocoa/Cocoa.h>

@interface BWMouseMotionWindow : NSWindow
{
    NSView *motionTarget;
}

// This is the view that should get any mouse motion events.

- (void) setMotionTarget: (NSView *) view;

@end // BWMouseMotionWindow

