#import "BWCGShaderView.h"

static NSString *axialBlurb = @"click and drag to set end points";
static NSString *radialBlurb = @"click and drag to set end points.  shift-drag to set start radius, option-drag to set end radius.";

@implementation BWCGShaderView

- (id) initWithFrame: (NSRect) frame
{
    if ((self = [super initWithFrame: frame])) {
        NSRect bounds = [self bounds];

        start = NSMakePoint(50, 50);
        end = NSMakePoint (NSMaxX(bounds), NSMaxY(bounds));

        startRadius = 60.0;
        endRadius = 30.0;

        axialShading = YES;
    }

    return (self);

} // initWithFrame

- (void) awakeFromNib
{
    [blurbField setStringValue: axialBlurb];

} // awakeFromNib

/*
A 1-in, N-out function, where N is one more (for alpha) than the
number of color components in the shading's color space. The input
value 0 corresponds to the color at the starting point of the
shading. The input value 1 corresponds to the color at the ending
point of the shading.
*/

static void evaluate (void *info, const float *in, float *out)
{
    float thing;
    thing = in[0];

    out[0] = thing;
    out[1] = thing;
    out[2] = thing;
    out[3] = 1.0;

} // evaluate


- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    [self cleanSlate];

    float domain[2] = { 0.0, 1.0 };	// 1-in function
    float range[8] = { 0.0, 1.0,	// N-out, RGBA
                       0.0, 1.0,
                       0.0, 1.0,
                       0.0, 1.0 };
    CGFunctionCallbacks callbacks = { 0, evaluate, NULL };

    CGFunctionRef shaderFunction;
    shaderFunction = CGFunctionCreate (self,	// info / rock / context
                                       1,	// # of inputs for domain
                                       domain,	// domain
                                       4,	// # of inputs for range
                                       range,	// range
                                       &callbacks);
					   
    CGColorSpaceRef deviceRGB;
    deviceRGB = CGColorSpaceCreateDeviceRGB ();
    
    CGShadingRef shader;
    if (axialShading) {
        shader = CGShadingCreateAxial (deviceRGB,	// colorspace
                                       cgpoint(start),  // start of axis
                                       cgpoint(end),    // end of axis
                                       shaderFunction,  // shader, 1-n, n-out
                                       extendStart,	// extend start
                                       extendEnd);      // extend end
    } else {
        shader = CGShadingCreateRadial (deviceRGB,	// colorspace
                                        cgpoint(start), // origin of start cir
                                        startRadius,
                                        cgpoint(end),	// origin of end cir
                                        endRadius,
                                        shaderFunction, // shader, 1-n, n-out
                                        extendStart,    // extend start
                                        extendEnd);     // extend end
    }

    CGContextSaveGState (context); {
        NSRect bounds = [self bounds];
        CGContextClipToRect (context, cgrect(bounds));
        CGContextDrawShading (context, shader);
    } CGContextRestoreGState (context);

    [self drawSpotAt: start  size: 4];
    [self drawSpotAt: end  size: 4];

    CGFunctionRelease (shaderFunction);
    CGColorSpaceRelease (deviceRGB);
    CGShadingRelease (shader);
    
} // drawRect


- (void) mouseDown: (NSEvent *) event
{
    NSPoint mouse = [self convertPoint: [event locationInWindow]
                          fromView: nil];
    if (axialShading) {
        start = end = mouse;
    } else {
        if ([event modifierFlags] & NSShiftKeyMask) {
            trackMode = kSizeStart;
            startRadius = distance(mouse, start);;
        } else if ([event modifierFlags] & NSAlternateKeyMask) {
            trackMode = kSizeEnd;
            endRadius = distance(mouse, end);
        } else {
            trackMode = kDragPoints;
            start = end = mouse;
        }
    }

    [self setNeedsDisplay: YES];

} // mouseDown


- (void) mouseDragged: (NSEvent *) event
{
    NSPoint mouse = [self convertPoint: [event locationInWindow]
                         fromView: nil];
    if (axialShading) {
        end = mouse;
    } else {
        switch (trackMode) {
        case kSizeStart:
            startRadius = distance(mouse, start);
            break;
        case kSizeEnd:
            endRadius = distance(mouse, end);
            break;
        case kDragPoints:
            end = mouse;
            break;
        }
    }

    [self setNeedsDisplay: YES];

} // mouseDragged


- (void) mouseUp: (NSEvent *) event
{
} // mouseUp


- (IBAction) extendStart: (id) sender
{
    extendStart = ([sender state] == NSOnState);
    [self setNeedsDisplay: YES];

} // extendStart


- (IBAction) extendEnd: (id) sender
{
    extendEnd = ([sender state] == NSOnState);
    [self setNeedsDisplay: YES];

} // extendEnd


- (IBAction) changeShading: (id) sender
{
    if ([sender selectedColumn] == 0) {
        axialShading = YES;
        [blurbField setStringValue: axialBlurb];
    } else {
        axialShading = NO;
        [blurbField setStringValue: radialBlurb];
    }
    [self setNeedsDisplay: YES];

} // changeShading


@end // BWCGShaderView
