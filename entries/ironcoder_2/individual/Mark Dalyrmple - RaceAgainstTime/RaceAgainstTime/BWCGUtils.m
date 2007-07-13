// Randomly usefl calls

#import "BWCGUtils.h"


// compute distance between two points

float distance (NSPoint p1, NSPoint p2)
{
    float xdist = p1.x - p2.x;
    float ydist = p1.y - p2.y;

    float dist = sqrt(xdist * xdist + ydist * ydist);

    return (dist);

} // distance



// Load a png image given the path.

CGImageRef pngImageAtPath(NSString *path)
{
    NSURL *url = [NSURL fileURLWithPath: path];
    
    CGDataProviderRef provider;
    provider = CGDataProviderCreateWithURL ((CFURLRef)url);

    CGImageRef image;
    image = CGImageCreateWithPNGDataProvider (provider, NULL, YES,
                                              kCGRenderingIntentDefault);
    CGDataProviderRelease (provider);

    return (image);

} // imageAtPath
