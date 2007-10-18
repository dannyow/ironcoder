// BWSpaceView - show a string in the view, with unicorns instead of space characters.

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface BWSpaceView : NSView
{
    // The words to display.
    NSArray *words;

    // How to display the text.
    NSDictionary *textAttributes;

    // Makes our animation go.
    NSTimer *timer;

    // The amount of space for the " "
    float space;

    // How much to increase (or decrease) the space every time the timer fires.
    float spaceIncrement;

    // This is the filter chain that draws the unicorns.    
    CIFilter *filter;

    // A bump filter is used - this is the center of the bump distortion.
    float bumpX, bumpY;

    // How much to move the bumps center on each timer firing.
    float bumpXincrement, bumpYincrement;
}


@end // BWSpaceView


