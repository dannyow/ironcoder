#import "BWCGShadowView.h"

@implementation BWCGShadowView

- (id) initWithFrame: (NSRect) frame
{
    if ((self = [super initWithFrame: frame])) {
        blur = 30.0;
        distance = 10.0;
        angle = 4.248738;
        point = NSMakePoint(300.0, 200.0);
    }

    return (self);

} // initWithFrame



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

        rect = CGRectInset(cgrect(rect), radius / 10.0, radius / 10.0);
        CGContextAddEllipseInRect (context, rect);

    } CGContextEOFillPath(context);

} // drawCircleAtPoint


- (void) drawStuffInContext: (CGContextRef) context
{
    CGContextSetRGBFillColor (context, 1.0, 0.0, 0.0, 1.0);
    [self drawCirclePathAtPoint: NSMakePoint(100.0, 100.0)
          radius: 100.0
          inContext: context];
    
    CGContextSetRGBFillColor (context, 1.0, 1.0, 0.0, 1.0);
    [self drawCirclePathAtPoint: NSMakePoint(150.0, 150.0)
          radius: 100.0
          inContext: context];
    
    CGContextSetRGBFillColor (context, 1.0, 0.0, 1.0, 1.0);
    [self drawCirclePathAtPoint: NSMakePoint(200.0, 100.0)
          radius: 100.0
          inContext: context];
    
} // drawStuffInContext


- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    [self cleanSlate];

    CGContextSaveGState (context); {

        if (drawShadow) {
            CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
            float stuff[] = { 0.5, 0.1, 0.1, 1.0 };

            CGColorRef color;
            color = CGColorCreate (colorspace, stuff);

            CGSize offset;
            offset.width = distance * sin(angle);
            offset.height = distance * cos(angle);
                                   
            CGContextSetShadowWithColor (context, offset, blur, color);
            CGColorSpaceRelease (colorspace);
            CGColorRelease (color);
        }

        if (useTransparencyLayer) {
            
            CGContextBeginTransparencyLayer (context, NULL); {
                [self drawStuffInContext: context];
            } CGContextEndTransparencyLayer (context);
            
            CGContextTranslateCTM (context, point.x - 150.0, point.y - 100.0);
            
            CGContextBeginTransparencyLayer (context, NULL); {
                [self drawStuffInContext: context];
            } CGContextEndTransparencyLayer (context);

        } else {
            [self drawStuffInContext: context];
            CGContextTranslateCTM (context, point.x - 150.0, point.y - 100.0);
            [self drawStuffInContext: context];
        }

    } CGContextRestoreGState (context);

} // drawRect


- (IBAction) drawShadow: (id) sender
{
    drawShadow = [sender state] == NSOnState;
    [self setNeedsDisplay: YES];

} // drawShadow


- (IBAction) useTransparency: (id) sender
{
    useTransparencyLayer = [sender state] == NSOnState;
    [self setNeedsDisplay: YES];
} // useTransparency


- (IBAction) setBlur: (id) sender
{
    blur = [sender floatValue];
    [self setNeedsDisplay: YES];

} // setBlur


- (IBAction) setAngle: (id) sender
{
    angle = [sender floatValue];
    [self setNeedsDisplay: YES];

} // setAngle


- (IBAction) setDistance: (id) sender
{
    distance = [sender floatValue];
    [self setNeedsDisplay: YES];

} // setDistance


- (void) mouseDown: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]
                  fromView: nil];
    point = mouse;
    [self setNeedsDisplay: YES];

} // mouseDown


- (void) mouseDragged: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]
                  fromView: nil];
    point = mouse;
    [self setNeedsDisplay: YES];

} // mouseDragged

@end // BWCGShadowView

