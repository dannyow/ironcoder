#import "BWCGSimple.h"

@implementation BWCGSimple

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    [self cleanSlate];

    NSRect bounds = [self bounds];
    bounds = NSInsetRect (bounds, 30, 30);

    CGContextSetLineWidth (context, 5.0);

    CGContextBeginPath(context); {
        CGContextAddRect (context, cgrect(bounds));
        CGContextSetRGBFillColor (context, 1.0, 0.9, 0.8, 1.0);
    } CGContextFillPath(context);

} // drawRect

@end // BWCGSimple

