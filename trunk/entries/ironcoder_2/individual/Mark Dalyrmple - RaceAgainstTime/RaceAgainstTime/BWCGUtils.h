// BWCGUtils.h -- interface to some random useful calls

#import <Cocoa/Cocoa.h>

// cast an NSRect to a CGRect.
#define cgrect(nsrect) (*(CGRect *)&(nsrect))

// cast an NSPoint to a CGPoint
#define cgpoint(nspoint) (*(CGPoint *)&(nspoint))

// distance formula! woo!
float distance (NSPoint p1, NSPoint p2);

// rads<->degs
#define degreesToRadians(degrees) ((degrees) * (3.14159 / 180.0))
#define radiansToDegrees(radians) ((radians) * (180.0 / 3.14159))

// Load a PNG image at a given path.
CGImageRef pngImageAtPath(NSString *path);



