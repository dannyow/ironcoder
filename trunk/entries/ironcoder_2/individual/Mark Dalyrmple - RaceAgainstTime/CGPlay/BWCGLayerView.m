#import "BWCGLayerView.h"

@implementation BWCGLayerView


- (void) populateWithFrame: (NSRect) frame
{
    int i;
    for (i = 0; i < pointCount; i++) {
        locations[i].x = random() % (int)(frame.size.width - 100);
        locations[i].y = random() % (int)(frame.size.height - 100);
    }

} // populateWithFrame


- (id) initWithFrame: (NSRect) frame
{
    if ((self = [super initWithFrame: frame])) {
        pointCount = 300;
        locations = malloc(sizeof(CGPoint) * pointCount);
    }

    return (self);

} // initWithFrame


- (void) awakeFromNib
{
    [self populateWithFrame: [self frame]];
} // awakeFromNib

#define BORDER 17
#define SPAN 22

CGPoint points[] = {
    { BORDER, BORDER + SPAN },
    { BORDER, BORDER + SPAN * 2 },
    { BORDER + SPAN, BORDER + SPAN * 2 },
    { BORDER + SPAN, BORDER + SPAN * 3 },
    { BORDER + SPAN * 2, BORDER + SPAN * 3 },
    { BORDER + SPAN * 2, BORDER + SPAN * 2 },
    { BORDER + SPAN * 3, BORDER + SPAN * 2 },
    { BORDER + SPAN * 3, BORDER + SPAN },
    { BORDER + SPAN * 2, BORDER + SPAN },
    { BORDER + SPAN * 2, BORDER },
    { BORDER + SPAN, BORDER },
    { BORDER + SPAN, BORDER + SPAN },
};

CGPoint lines[] = {
    { BORDER, BORDER },
    { BORDER + SPAN * 3, BORDER + SPAN * 3 },
    
    { BORDER, BORDER * 2},
    { BORDER + SPAN * 3, BORDER * 2 + SPAN * 3 },
    
    { BORDER, BORDER * 3},
    { BORDER + SPAN * 3, BORDER * 3 + SPAN * 3 },

    { BORDER, BORDER + SPAN * 3 },
    { BORDER + SPAN * 3, BORDER },
    
    { BORDER, BORDER * 2 + SPAN * 3 },
    { BORDER + SPAN * 3, BORDER * 2},
    
    { BORDER, BORDER * 3 + SPAN * 3 },
    { BORDER + SPAN * 3, BORDER * 3},
};


- (void) drawStuffInContext: (CGContextRef) context
{
    CGContextBeginPath(context); {
        int count = sizeof(points) / sizeof(*points);
        CGContextMoveToPoint (context, points[0].x, points[0].y);

        int i;
        for (i = 1; i < count; i++) {
            CGContextAddLineToPoint (context, points[i].x, points[i].y);
        }
        CGContextClosePath (context);

        CGContextSetRGBFillColor (context, 0.5, 0.2, 0.7, 0.4);
    } CGContextFillPath(context);

    CGContextBeginPath(context); {
        int count = sizeof(lines) / sizeof(*lines);
        int i;
        for (i = 0; i < count; i += 2) {
            CGContextMoveToPoint (context, lines[i].x, lines[i].y);
            CGContextAddLineToPoint (context, lines[i+1].x, lines[i+1].y);
        }

        CGContextSetRGBFillColor (context, 0.4, 0.4, 0.7, 0.6);
    } CGContextStrokePath(context);

    CGContextBeginPath(context); {
        CGRect rect = CGRectMake(BORDER, BORDER,
                                 BORDER + SPAN, BORDER + SPAN);
        CGContextAddEllipseInRect(context, rect);
        CGContextSetRGBFillColor (context, 0.1, 0.4, 0.4, 0.3);
    } CGContextFillPath(context);

} // drawStuffInContext


- (void) makeLayerInContext: (CGContextRef) enclosingContext
{
    layer = CGLayerCreateWithContext (enclosingContext, CGSizeMake(100, 100),
                                      NULL); // options - unused in Tiger
    CGContextRef context;
    context = CGLayerGetContext (layer);

    [self drawStuffInContext: context];

} // makeLayer


- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    [self cleanSlate];

    if (layer == NULL) {
        [self makeLayerInContext: context];
    }

    int i;

    if (useLayer) {
        for (i = 0; i < pointCount; i++) {
            CGContextDrawLayerAtPoint (context, locations[i], layer);
        }
    } else {
        for (i = 0; i < pointCount; i++) {
            CGContextSaveGState(context); {
                CGContextTranslateCTM (context, locations[i].x, locations[i].y);
                [self drawStuffInContext: context];
            } CGContextRestoreGState(context);
        }
    }
    
} // drawRect


- (IBAction) useLayer: (id) sender
{
    useLayer = [sender state] == NSOnState;
    [self setNeedsDisplay: YES];

} // useLayer


- (void) moveEm: (NSTimer *) timer
{
    int i;
    for (i = 0; i < pointCount; i++) {
        int biasx = random() % 2 ? 1 : -1;
        int biasy = random() % 2 ? 1 : -1;

        locations[i].x += biasx * (random() % 3);
        locations[i].y += biasy * (random() % 3);
    }

    [self setNeedsDisplay: YES];

} // moveEm


- (IBAction) animate: (id) sender
{
    if ([sender state] == NSOnState) {
        timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 30.0
                         target: self
                         selector: @selector(moveEm:)
                         userInfo: nil
                         repeats: YES];
        [timer retain];
    } else {
        [timer invalidate];
        [timer release];
    }

} // animate


- (void) setFrame: (NSRect) frame
{
    [super setFrame: frame];
    [self populateWithFrame: frame];
} // setBounds

@end // BWCGLayerView

