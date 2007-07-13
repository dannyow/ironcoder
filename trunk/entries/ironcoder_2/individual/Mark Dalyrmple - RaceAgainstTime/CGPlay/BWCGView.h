#import <Cocoa/Cocoa.h>

#define cgrect(nsrect) (*(CGRect *)&(nsrect))
#define cgpoint(nspoint) (*(CGPoint *)&(nspoint))

float distance (NSPoint p1, NSPoint p2);


@interface BWCGView : NSView
{
}

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context;

// draw white background and black border
- (void) cleanSlate;
- (void) drawSpotAt: (NSPoint) spot  size: (int) size;

@end // BWCGView

