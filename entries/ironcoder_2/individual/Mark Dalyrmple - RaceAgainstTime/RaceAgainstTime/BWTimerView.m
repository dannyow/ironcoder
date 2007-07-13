#import "BWTimerView.h"
#include <sys/time.h> // for gettimeofday

@implementation BWTimerView

// clean up or mess

- (void) dealloc
{
    [self stop]; // disposes with timer

    // nuke the layers
    int i;
    for (i = 0; i < 10; i++) {
        CGLayerRelease (digitLayers[i]);
    }

    [super dealloc];

} // dealloc


// --------------------------------------------------
// Begin LED segment stuff.  This probalby should be moved into
// another class for cleanliness.  No time... No time...


// creates a horziontal hexagon that looks like an LED segment:
//   ________________________
//  /                        \     .
// /                          \    .
// \                          /
//  \________________________/
// the segment was originally designed in OmniGrackle to get the
// fit of segments just right.   The entity ended up being 26 grid
// squares long, which is why 26 appears semi-inexplicably.
// this shape is one unit long, presuming someone else will scale
// and rotate it to draw the final result

- (CGPathRef) LEDSegmentPath
{
    CGMutablePathRef path;
    path = CGPathCreateMutable();

    CGAffineTransform *identity = NULL;

    CGPathMoveToPoint (path, identity,     0.0,        4.0 / 26.0);
    CGPathAddLineToPoint (path, identity,  4.0 / 26.0, 0.0);
    CGPathAddLineToPoint (path, identity, 22.0 / 26.0, 0.0);
    CGPathAddLineToPoint (path, identity,  1.0,        4.0 / 26.0);
    CGPathAddLineToPoint (path, identity, 22.0 / 26.0, 8.0 / 26.0);
    CGPathAddLineToPoint (path, identity,  4.0 / 26.0, 8.0 / 26.0);
    CGPathCloseSubpath (path);

    return (path);
    
} // LEDSegmentPath


// Now for the drawing of the segments, which are numbered like this:
//   6
//  4 5
//   3
//  1 2
//   0

// to draw a segment in the right place, we need the location of the
// the origin of the segment, along with a rotation to turn the horizontal
// segment into a vertical one.

typedef struct segmentPosition {
    float x, y, angle;
} segmentPosition;

// exact values were found by tinkering with drawing until it looked
// acceptable

static segmentPosition pos[] = {
    { 0.0,                0.0,                   0.0 },
    { 3.0 / 26.0,         6.0 / 26.0,           90.0 },
    { 1.0 + 5.0 / 26.0,   6.0 / 26.0,           90.0 },
    { 0.0,                1.0 + 4 / 26.0,        0.0 },
    { 3.0 / 26.0,         1.0 + 10.0 / 26.0,    90.0 },
    { 1.0 + 5.0 / 26.0,   1.0 + 10.0 / 26.0,    90.0 },
    { 0.0,                2.0 + 8.0 / 26.0,      0.0 }
};

// what segments to draw for each digit?  Make a bitmask!
// Set the bit to indicate whether the corresponding segment
// should be drawn.

static int segmentMask[] = {
    0x77, // 0:  6 5 4   2 1 0
    0x24, // 1:    5     2
    0x6B, // 2:  6 5   3   1 0
    0x6D, // 3:  6 5   3 2   0
    0x3C, // 4:    5 4 3 2
    0x5D, // 5:  6   4 3 2   0
    0x5F, // 6:  6   4 3 2 1 0
    0x64, // 7:  6 5     2
    0x7F, // 8:  6 5 4 3 2 1 0
    0x7D  // 9:  6 5 4 3 2   0
};


// draw the the digit into a context.

- (void) draw7SegmentsInContext: (CGContextRef) context
                       forValue: (int) value
{
    assert(value >= 0 && value <= 9);

    // this path will get drawn repeatedly as the
    // current context gets translated, rotated, folded, spindled,
    // and mutilated.

    CGPathRef path = [self LEDSegmentPath];

    // this controls which segments get drawn
    int mask = segmentMask[value];

    // violence will be wreaked unto the context, so save off
    // the current state.
    CGContextSaveGState(context); {

        // make line drawing minimal,
        // otherwise get weird pixel artifacts when drawn small.
        CGContextSetLineCap (context, kCGLineCapButt);
        CGContextSetLineJoin (context, kCGLineJoinBevel);

        CGContextSetRGBFillColor (context, 
                                  [segmentColor redComponent],
                                  [segmentColor greenComponent],
                                  [segmentColor blueComponent],
                                  1.0);

        // all segments will be put into path that will get drawn
        CGContextBeginPath(context); {

            int i;
            for (i = 0; i < 7; i++) {

                // consult the mask to know whether this segment
                // should be drawn.
                if (!((1 << i) & mask)) continue;

                // reset the Current Transformation Matrix after
                // each segment, so that there won't be confusion
                // as operators get piled on each other
                CGContextSaveGState(context); {
                    CGContextTranslateCTM (context, pos[i].x, pos[i].y);
                    CGContextRotateCTM (context, 
                                        degreesToRadians(pos[i].angle));
                    CGContextAddPath (context, path);
                } CGContextRestoreGState(context);
            }

        } CGContextDrawPath(context, kCGPathFillStroke);

    } CGContextRestoreGState(context);

    CGPathRelease (path);
    
} // draw7SegmentsInContext


// Creeate a CGLayer for each digit.  This is a performance boost
// (less work each time to draw the segments), as well as simiplifying
// the drawing, since all the rotations and scalings and whatnot
// have already been done

- (void) makeDigitLayersInContext: (CGContextRef) enclosingContext
{
    int i;
    for (i = 0; i < 10; i++) {
        // make sure the layer is big enough to hold the digit.
        // it's ok if it's too big - unused portions just won't
        // get rendered
        digitLayers[i] = CGLayerCreateWithContext
            (enclosingContext,  CGSizeMake(scale * 3, scale * 6), NULL);

        // draw the digit into the layer's context.
        CGContextRef context;
        context = CGLayerGetContext (digitLayers[i]);

        CGContextSaveGState(context); {
            // initial value determined by fiddling around.
            CGContextTranslateCTM (context, 5.0, 0.0);
            // the segments are unit lenght - increase the size
            // of the unit.
            CGContextScaleCTM (context, scale, scale);

            // scaling the CTM also scales the line width, leading
            // to ridiculous results.  Make the line width
            // proportionally smaller. on screen it'll be one
            // pixel, modulo roundouff.
            CGContextSetLineWidth (context, 1.0 / scale);
            
            [self draw7SegmentsInContext: context  forValue: i];
            
        } CGContextRestoreGState(context);
    }

} // makeDigitLayersInContext


// draw the digits as 7-segment LEDs 
// assumes there are 5 digits.

- (void) drawTimeDigits: (int *) digits
              inContext: (CGContextRef) context
{
    // the values get drawn as XX : XX . X

    CGContextSaveGState(context); {
        // how far to advance the current point along the baseline
        // for each digit drawn
        float hscale = scale + scale / 1.5;
        float advance = 0;

        int i;
        for (i = 0; i < 5; i++) {
            // draw the digit
            CGContextDrawLayerAtPoint (context, 
                                       CGPointMake(advance, 0.0),
                                       digitLayers[digits[i]]);
            // move to the next location
            advance += hscale;

            // after these guys, put in some extra space and draw
            // a colon or a dot for a spearator.

            if (i == 1 || i == 3) {
                CGContextSaveGState(context); {
                    CGContextSetRGBFillColor (context, 
                                              [segmentColor redComponent],
                                              [segmentColor greenComponent],
                                              [segmentColor blueComponent],
                                              1.0);

                    // !!! really should genercize this - if you change
                    // !!! the size, the dots will go to the wrong place.
                    CGRect dotrect;
                    dotrect = CGRectMake(advance + scale / 2.0 - 3.0,
                                         scale, 
                                         scale / 3, scale / 3);
                    CGContextFillEllipseInRect (context, dotrect);
                    CGContextStrokeEllipseInRect (context, dotrect);
                    
                    // only a single dot between secs and tenths.
                    if (i == 1) {
                        dotrect = CGRectMake(advance + scale / 2.0 - 3.0,
                                             scale + 10.0, 
                                             scale / 3, scale / 3);
                        CGContextFillEllipseInRect (context, dotrect);
                        CGContextStrokeEllipseInRect (context, dotrect);
                    }

                } CGContextRestoreGState(context);

                // give it some extra space for the dots
                advance += scale;
            }
        }

    } CGContextRestoreGState(context);

} // drawTimeDigits


// draw the timer

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    // chosen via fiddling til it looked OK.
    scale = 15;

    [self cleanSlate];

    // figure out the digits to draw
    int *minsecten = [self minutesSecondsTenths];
    int minutes = minsecten[0];
    int seconds = minsecten[1];
    int tenths = minsecten[2];

    int digits[5];  //  MM SS T

    // zero-pad for 0-9 minutes
    if (minutes < 10) {
        digits[0] = 0;
    } else {
        digits[0] = (minutes / 10) % 10;
    }

    digits[1] = minutes % 10;

    // zero-pad for 0-9 seonds
    if (seconds < 10) {
        digits[2] = 0;
    } else {
        digits[2] = (seconds / 10) % 10;
    }
    digits[3] = seconds % 10;

    digits[4] = tenths;

    CGContextSaveGState(context); {
        // move to a place not on the border
        CGContextTranslateCTM (context, 5.0, 8.0);

        // make the digit cache lazily
        if (!haveDigitLayers) {
            haveDigitLayers = YES;
            [self makeDigitLayersInContext: context];
        }

        // draw the goodies
        [self drawTimeDigits: digits
              inContext: context];

    } CGContextRestoreGState(context);

} // drawRect


// take the start and end measured times and calculate the 
// minutes, seconds, and tenths

- (void) updateTimes
{
    long deltasecs, deltausecs;
    deltasecs = last.tv_sec - start.tv_sec;
    deltausecs = last.tv_usec - start.tv_usec;

    if (deltausecs < 0) {
        deltausecs += 1000000;
        deltasecs -= 1;
    }

    int minutes = deltasecs / 60;
    int seconds = deltasecs % 60;
    int tenths = (int)(deltausecs / 100000.0) % 10;

    minutesSecondsTenths[0] = minutes;
    minutesSecondsTenths[1] = seconds;
    minutesSecondsTenths[2] = tenths;

} // updateTimes


// timer fired.  Poll the current time and update the cached
//  M/S/T values.  We don't just increase a counter with each
// timer, in case things get slow and some tenths of a second get
// dropped

- (void) tick: (NSTimer *) timer
{
    [self setNeedsDisplay: YES];

    gettimeofday (&last, NULL);

    [self updateTimes];

} // tick


// start timing.  This resets the M/S/T values back to zero

- (void) start
{
    [self stop];

    running = YES;

    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 11.0
                     target: self
                     selector: @selector(tick:)
                     userInfo: self
                     repeats: YES];
    [timer retain];

    gettimeofday (&start, NULL);
    gettimeofday (&last, NULL);

    [self updateTimes];

} // start


// stop the timing.

- (void) stop
{
    running = NO;

    [timer invalidate];
    [timer release];
    timer = nil;

} // stop


// if we get moved out of the window, don't do any more timing.

- (void) viewDidMoveToSuperview
{
    if ([self superview] == nil) {
        [self stop];
    }

} // didMoveToSuperview


// let folks know what we've discovered time-wise

- (int *) minutesSecondsTenths
{
    return (minutesSecondsTenths);

} // minutesSecondsTenths


// set the time to display (handy for static displayes, like the
// previous low score)

- (void) setTime: (int*) time
{
    int i;
    for (i = 0; i < 3; i++) {
        minutesSecondsTenths[i] = time[i];
    }
    [self setNeedsDisplay: YES];

} // setTime


// this is the color to draw the LED segments

- (void) setSegmentColor: (NSColor *) color
{
    [segmentColor release];
    segmentColor = [[color colorUsingColorSpaceName: NSDeviceRGBColorSpace] 
                       retain];

    [self setNeedsDisplay: YES];

} // setSegmentColor

@end // BWTimerView

