// BWTimerView.h -- draws the count-up timer.  Also does the timing itself.
//  Yeah, it's kind of an awkward fit, but given time constraints, I'm
//  happy that it just works.

#import <Cocoa/Cocoa.h>
#import "BWCGView.h"

@interface BWTimerView : BWCGView
{
    NSTimer *timer; // Time out for Timer

    // are we currently running the timer?  or just sititng there?
    BOOL running;

    // time when timing started, and the last time the time was
    // consulted.
    struct timeval start, last;

    // how large to draw the LED segments
    float scale;

    // CGLayers are used to store individual digits (improves
    // performance and simplifies drawing

    // have we generated the layers?  If not, create them
    BOOL haveDigitLayers;

    // the precomputed drawing for each digit
    CGLayerRef digitLayers[10];

    // the time to display on the screen
    int minutesSecondsTenths[3]; // [0] == MM [1] == SS [2] == T

    // what color to draw the LED segments.
    NSColor *segmentColor;
}

// start the timer and animate the current time interval
- (void) start;

// stop the timer
- (void) stop;

// get the time, index zero is minutes.
- (int *) minutesSecondsTenths;

// what color to draw the LED segments
- (void) setSegmentColor: (NSColor *) color;

// display this time, sucka.
- (void) setTime: (int*) time;

@end // BWTimerView

