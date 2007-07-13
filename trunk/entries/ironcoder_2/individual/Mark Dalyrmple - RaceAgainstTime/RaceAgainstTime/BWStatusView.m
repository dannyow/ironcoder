// Container for the timer views

#import "BWStatusView.h"


@implementation BWStatusView


- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    // But in purple, I'm *stunning*.

    [[NSColor purpleColor] set];
    NSRectFill (rect);

} // drawRect


@end // BWStatusView

