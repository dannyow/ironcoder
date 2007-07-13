#import "BWCGPatternView.h"

@implementation BWCGPatternView

- (CGImageRef) getImageFromPath: (NSString *) path
{
    NSURL *url = [NSURL fileURLWithPath: path];
    CGImageSourceRef imageSource;
    imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);

    CFDictionaryRef properties;
    properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);

#if 0
    float xdpi, ydpi;

    CFNumberRef val;
    val = CFDictionaryGetValue(properties, kCGImagePropertyDPIWidth);
    CFNumberGetValue(val, kCFNumberFloatType, &xdpi);

    val = CFDictionaryGetValue(properties, kCGImagePropertyDPIHeight);
    CFNumberGetValue(val, kCFNumberFloatType, &ydpi);
#endif

    CGImageRef cgimage;
    cgimage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

    CFRelease (imageSource);

    return (cgimage);

} // getImageFromPath


- (id) initWithFrame: (NSRect) frame
{
    if ((self = [super initWithFrame: frame])) {

        NSString *path;
        path = [[NSBundle mainBundle] pathForResource: @"background"  
                                      ofType: @"gif"];
        image = [self getImageFromPath: path];
        point = NSMakePoint (100, 100);
    }

    return (self);

}  // initWithFrame


static void drawImage (void *info, CGContextRef context)
{
    BWCGPatternView *view = (BWCGPatternView *) info;
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size.width = CGImageGetWidth(view->image);
    rect.size.height = CGImageGetHeight(view->image);

    CGContextDrawImage (context, rect, view->image);

} // drawImage


- (void) drawCirclePathAtPoint: (NSPoint) center   radius: (float) radius
                     inContext: (CGContextRef) context
{
    CGContextBeginPath(context); {

        CGRect rect;
        rect.origin.x = center.x - radius / 2.0;
        rect.origin.y = center.y - radius / 2.0;
        rect.size = CGSizeMake(radius, radius);
        
        CGContextSetLineWidth (context, 3.0);
        CGContextAddEllipseInRect (context, rect);

        rect = CGRectInset(cgrect(rect), radius / 3.0, radius / 3.0);
        CGContextAddEllipseInRect (context, rect);

    } CGContextEOFillPath(context);

} // drawCircleAtPoint



- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    [self cleanSlate];

    CGContextSaveGState(context); {
        CGPatternRef pattern;
        CGRect imagerect = CGRectMake(0, 0, CGImageGetWidth(image),
                                      CGImageGetHeight(image));
        
        CGPatternCallbacks callbacks = { 0, drawImage, NULL };
        
        pattern = CGPatternCreate (self, imagerect, CGAffineTransformIdentity,
                                   CGImageGetWidth(image),
                                   CGImageGetHeight(image),
                                   kCGPatternTilingNoDistortion,
                                   YES,
                                   &callbacks);
        
        CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
        CGContextSetFillColorSpace (context, space);
        float alpha[1] = { 1.0 };
        CGContextSetFillPattern (context, pattern, alpha);
        

        CGContextTranslateCTM (context, point.x - 100, point.y - 100);
        [self drawCirclePathAtPoint: NSMakePoint(100.0, 100.0)
              radius: 100.0
              inContext: context];
        
        [self drawCirclePathAtPoint: NSMakePoint(150.0, 150.0)
              radius: 100.0
              inContext: context];
        
        [self drawCirclePathAtPoint: NSMakePoint(200.0, 100.0)
              radius: 100.0
              inContext: context];
        
        CGPatternRelease (pattern);

    } CGContextRestoreGState(context);

} // drawRect


- (void) mouseDown: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]  fromView: nil];

    point = mouse;
    [self setNeedsDisplay: YES];

} // mouseDown


- (void) mouseDragged: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]  fromView: nil];

    point = mouse;
    [self setNeedsDisplay: YES];

} // mouseDragged


@end // BWCGPatternView


