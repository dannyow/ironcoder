// Base class for running games

#import "BWRaceView.h"
#import "AppController.h"


@implementation BWRaceView

// Designatied initializer.

- (id) initWithFrame: (NSRect) frame
          controller: (AppController *) c
{
    if ((self == [super initWithFrame: frame])) {
        controller = c;
        [self resetBestTime];
        [self loadBestTime];
    }

    return (self);

} // initWithFrame


// Subclasses should override this - the display name in the main
// menu

- (NSString *) name
{
    return (@"IMA DORQ");
} // name



// Subclasses should override this - the key to use in the application
// preferences to store the low score.  return nil to say you don't
// want any preferences autosaved

- (NSString *) bestTimePrefKey
{
    return (nil);
} // bestTimePrefKey



// Draw something reasonable until subclasses get around to
// doing their drawing.

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    [self cleanSlate];
} // drawRect


- (AppController *) controller
{
    return (controller);
} // controller


// necessary to have this to eat unhandled wave motion guns, otherwise
// AppKit goes into a stupid infinite loop.

- (void) mouseMoved: (NSEvent *) event
{
} // mouseMoved



// cheat and go into cloud-cocoa-land to figure out the string
// dimensions.  It doesn't always jive with the rectangle covered
// by CG.

- (NSRect) boundsForMenuText: (NSString *) text
                        font: (const char *) fontName
                        size: (float) size
                      origin: (NSPoint) origin
{
    // make a font
    NSString *fn;
    fn = [NSString stringWithCString: fontName
                   encoding: NSUTF8StringEncoding];

    NSFont *font = [NSFont fontWithName: fn  size: size];

    // use it for the string attributesx
    NSDictionary *attributes;
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   font, NSFontAttributeName,
                               nil];

    // get the size, and then make a rectangle starting at the
    // given origin.
    NSSize stringsize = [text sizeWithAttributes: attributes];

    NSRect bounds;
    bounds.size = stringsize;
    bounds.origin = origin;

    // adjust for differences in CG and Cocoa views of text placement.
    bounds.origin.y += [font descender];

    return (bounds);
    
} // boundsForMenuText



// draw a chunk of text at a given point in a given font and a given size,
// i na given context, and maybe with a shadow.  Draws in blue.

- (void) drawMenuText: (NSString *) text
                 font: (const char *) fontName
                 size: (float) size
               origin: (NSPoint) origin 
            inContext: (CGContextRef) context
           drawShadow: (BOOL) drawShadow
{
    CGContextSaveGState(context); {

        // use a pinkish gray shadow
        if (drawShadow) {
            float stuff[] = { 0.3, 0.1, 0.1, 1.0 };

            CGColorRef color;
            color = CGColorCreate ([self rgbColorSpace], stuff);

            // the shadow gets placed directly underneath the text, like
            // it's floating on a fluffy little cloud, amongst the
            // happy little trees.  There are no misteaks, only
            // happy little accidents.
            CGSize offset = CGSizeZero;

            // tell the context to shadowize everything that gets
            // drawn.
            CGContextSetShadowWithColor (context, offset, 30.0, color);
            CGColorRelease (color);
        }

        // move to the origin, since text drawing starts at 0,0
        CGContextTranslateCTM (context, origin.x, origin.y);

        CGContextSetTextMatrix (context, CGAffineTransformIdentity);
        CGContextSelectFont (context, fontName, size,
                             kCGEncodingMacRoman);

        CGContextSetRGBFillColor (context, 0.0, 0.0, 1.0, 1.0);
        CGContextShowTextAtPoint (context, 0.0, 0.0, [text cString],
                                  [text length]);
    } CGContextRestoreGState(context);    

} // drawMenuText



// return the current low score

- (int *) bestTime
{
    return (bestTime);
} // bestTime


// stick the low score to the user preferences.
- (void) saveBestTime
{
    NSString *prefKey = [self bestTimePrefKey];

    // only save if the view actually wants them saved
    if (prefKey != nil) {

        NSArray *times;
        times = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt: bestTime[0]],
                         [NSNumber numberWithInt: bestTime[1]],
                         [NSNumber numberWithInt: bestTime[2]], nil];

        [[NSUserDefaults standardUserDefaults]
            setObject: times
            forKey: prefKey];

        // new olympic sport, synchronized saving.
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

} // saveBestTime



// fetch the current low score (if it exists) from the user preferences
- (void) loadBestTime
{
    NSString *prefKey = [self bestTimePrefKey];

    // only load if the view actually wants them loaded
    if (prefKey != nil) {

        NSArray *times;
        times = [[NSUserDefaults standardUserDefaults]
                    objectForKey: prefKey];

        if (times != nil) {
            int i;
            for (i = 0; i < 3; i++) {
                bestTime[i] = [[times objectAtIndex: i] intValue];
            }
        }
    }

} // loadBestTime



// forget that we have a low score

- (void) resetBestTime
{
    bestTime[0] = bestTime[1] = bestTime[2] = 99;
} // resetBestTime


@end // BWRaceView
