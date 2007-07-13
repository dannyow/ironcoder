// BWCGView.h -- NSView that makes using CG stuff marginally simpler

#import <Cocoa/Cocoa.h>
#import "BWCGUtils.h" // these are useful for subclassses, so go ahead and
		      // and pull them in.


@interface BWCGView : NSView
{
    CGColorSpaceRef rgbColorSpace;
}

// subclasses override this rather than drawRect: to do their
// drawing.  The context is the CGContext for the view.

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context;

// Handy way to get the device rgb color space, rather than having
// to create one and remember to dispose of it

- (CGColorSpaceRef) rgbColorSpace;

// draw white background and black border.  Handy for making a clean
// canvas to piddle on.

- (void) cleanSlate;

@end // BWCGView

