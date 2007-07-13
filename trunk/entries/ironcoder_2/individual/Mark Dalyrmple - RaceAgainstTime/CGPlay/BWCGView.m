#import "BWCGView.h"


@implementation BWCGView

#define cgrect(nsrect) (*(CGRect *)&(nsrect))

- (void) drawRect: (NSRect) rect
{
    NSGraphicsContext *cocoaContext = [NSGraphicsContext currentContext];
    CGContextRef context = (CGContextRef)[cocoaContext graphicsPort];

    [self drawRect: rect  inContext: context];

} // drawRect



- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    assert (!"subclasses should override me");

} // drawRect inContext


- (void) cleanSlate
{
    NSRect bounds = [self bounds];

    [[NSColor whiteColor] set];
    NSRectFill (bounds);

    [[NSColor blackColor] set];
    NSFrameRect (bounds);

} // cleanSlate


- (void) drawSpotAt: (NSPoint) spot  size: (int) size
{
    NSRect rect;
    rect.origin.x = spot.x - size / 2.0;
    rect.origin.y = spot.y - size / 2.0;
    rect.size = NSMakeSize (size, size);

    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect: rect];

    [NSGraphicsContext saveGraphicsState]; {
        [NSColor blackColor];
        [path fill];
    } [NSGraphicsContext restoreGraphicsState];

} // drawSpotAt


@end // BWCGView


float distance (NSPoint p1, NSPoint p2)
{
    float xdist = p1.x - p2.x;
    float ydist = p1.y - p2.y;

    float dist = sqrt(xdist * xdist + ydist * ydist);

    return (dist);

} // distance


