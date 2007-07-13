//  NSView that makes using CG stuff marginally simpler

#import "BWCGView.h"

@implementation BWCGView

// clean up any messes.

- (void) dealloc
{
    CGColorSpaceRelease (rgbColorSpace);
    
    [super dealloc];

} // dealloc



// Vector drawing to the new method that takes the CGContext.

- (void) drawRect: (NSRect) rect
{
    NSGraphicsContext *cocoaContext = [NSGraphicsContext currentContext];
    CGContextRef context = (CGContextRef)[cocoaContext graphicsPort];

    [self drawRect: rect  inContext: context];

} // drawRect



// The whole point of being a BWCGView is to override this, so you
// better gosh-darn better override this!

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    assert (!"subclasses should override me");

} // drawRect inContext



// erase the view to white and put a black border around it.

- (void) cleanSlate
{
    NSRect bounds = [self bounds];

    [[NSColor whiteColor] set];
    NSRectFill (bounds);

    [[NSColor blackColor] set];
    NSFrameRect (bounds);

} // cleanSlate


// return the device rgb color space - handy utility for folks who need
// to access the color space, and don't want to worry about cleaning up
// afterwards.

- (CGColorSpaceRef) rgbColorSpace
{
    if (rgbColorSpace == NULL) {
        rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    }

    return (rgbColorSpace);

} // rgbColorSpace


@end // BWCGView
