// Main Menu of the app

#import "BWMenuView.h"
#import "BWShader.h"
#import "AppController.h"
#import "BWCGUtils.h"

// the font/size to display the menu of available games.

#define MENU_FONT "Papyrus"
#define MENU_SIZE 30


@implementation BWMenuView

// get things rolling
- (id) initWithFrame: (NSRect) frame
          controller: (AppController *) c
{
    if ((self = [super initWithFrame: frame  controller: c])) {

        // load the happy clock guy
        NSString *iconPath;
        iconPath = [[NSBundle mainBundle] pathForResource: @"clock-happy"
                                          ofType: @"png"];
        appIcon = pngImageAtPath (iconPath);
        assert(iconPath);

        appIconBounds.origin = NSZeroPoint;
        appIconBounds.size.width = CGImageGetWidth(appIcon);
        appIconBounds.size.height = CGImageGetHeight(appIcon);

        // arbitrary start colors for the color ramp displayed in the
        // app title.
        startRgb[0] = 128;
        startRgb[1] = 52;
        startRgb[2] = 200;

        endRgb[0] = 37;
        endRgb[1] = 193;
        endRgb[2] = 8;

        // start all values incrementing upward.  When the values
        // exceed 255, it reverses and starts decreasing the values.
        startUp[0] = startUp[1] = startUp[2] = YES;
        endUp[0] = endUp[1] = endUp[2] = YES;

        selectedMenu = -1;
    }

    return (self);

} // initWithFrame


// clean up the mess.

- (void) dealloc
{
    [throbber invalidate];
    [throbber release];
    [gameViews release];

    CGImageRelease (appIcon);

    [super dealloc];

} // dealloc


// Determine where to draw the title for a given game.  The 0th item
// starts at the top.

- (NSPoint) originForMenuIndex: (int) index
{
    // 245, 272 is a good starting place.  and assume that each menu
    // thingie is 55 pixels tall

    NSPoint basePoint = NSMakePoint(245.0, 259.0);

    basePoint.y -= index * 55;
    
    return (basePoint);

} // originForMenuIndex


// return the name of the given view.  If the view has a current
// low score, attach that to the name.

- (NSString *) nameWithTime: (BWRaceView *) view
{
    NSString *name;

    int *viewBestTime = [view bestTime];

    if (viewBestTime[0] == 99) {
        name = [view name];

    } else {
        name = [NSString stringWithFormat: @"%@ (time to beat: %02d:%02d.%d)",
                         [view name], viewBestTime[0], 
                         viewBestTime[1], viewBestTime[2]];
    }
    return (name);

} // nameWithTime



// draw the menu (the list of game names).  Draw the current item
// (the one the mouse is over) with a shadowed background to highlight
// it

- (void) drawMenuInContext: (CGContextRef) context
{
    int i = 0;
    for (i = 0; i < [gameViews count]; i++) {
        BWRaceView *view = [gameViews objectAtIndex: i];;

        NSString *name = [self nameWithTime: view];

        [self drawMenuText: name
              font: MENU_FONT
              size: MENU_SIZE
              origin: [self originForMenuIndex: i]
              inContext: context
              drawShadow: (selectedMenu == i)];
    }

} // drawMenuInContext



// Given a chunk of text and some visual attributes, 
// use it for the clipping path.  You'll want to save and restore
// the gstate around this call

- (void) clipText: (NSString *) text  size: (float) size
           origin: (NSPoint) origin  angle: (float) angle
        inContext: (CGContextRef) context
{
    // stroke the text, giving an outline, the clip to the
    // interior of the text so it can be drawn through.
    CGContextSetTextDrawingMode (context, kCGTextFillStrokeClip);

    // move the world to the start of the text
    CGContextTranslateCTM (context, origin.x, origin.y);
    CGContextRotateCTM (context, degreesToRadians(angle));

    // have the text conform to the current transformation matrix
    CGContextSetTextMatrix (context, CGAffineTransformIdentity);

    // what to draw
    CGContextSelectFont (context, "Marker Felt Wide", size,
                         kCGEncodingMacRoman);

    // and draw+clip
    CGContextShowTextAtPoint (context, 0.0, 0.0, [text cString],
                              [text length]);

} // clipText


// kitchen sink of a lot of drawing stuff
- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    NSRect bounds = [self bounds];

    // white background with thin black rule.
    [self cleanSlate];


    // stick the clock guy into the upper-right

    NSRect appIconLocation = appIconBounds;
    appIconLocation.origin.x = 
        bounds.size.width - appIconBounds.size.width - 2.0;
    appIconLocation.origin.y = 
        bounds.size.height - appIconBounds.size.height - 2.0;

    CGContextDrawImage (context, cgrect(appIconLocation), appIcon);

    CGContextSaveGState(context); {
        // make a clipping region to the text path
        [self clipText: @"Race Against Time"
              size: 90
              origin: NSMakePoint(38.0, 248.0)
              angle: 20.0
              inContext: context];
        
        // then draw a color ramp behind it

        NSColor *startColor, *endColor;
        startColor = [NSColor colorWithDeviceRed: startRgb[0] / 255.0
                                  green: startRgb[1] / 255.0
                                  blue: startRgb[1] / 255.0
                                  alpha: 1.0];
        endColor = [NSColor colorWithDeviceRed: endRgb[0] / 255.0
                            green: endRgb[1] / 255.0
                            blue: endRgb[1] / 255.0
                            alpha: 1.0];
        
        BWAxialShader *shader;
        shader = [BWAxialShader shaderWithStartColor: startColor
                                endColor: endColor
                                startPoint: NSMakePoint(0.0, 0.0)
                                endPoint: NSMakePoint(300.0, 300.0)
                                extendStart: YES
                                extendEnd: YES
                                colorSpace: [self rgbColorSpace]];
        [shader drawInContext: context];
        
    } CGContextRestoreGState(context);

    // draw the menu items
    [self drawMenuInContext: context];

    // draw the help, as it is.  I was too lazy to figure out how

    // to do wrapping of text to have per-game help information.
    NSPoint blurbPoint = [self originForMenuIndex: [gameViews count] + 1];
    blurbPoint.x -= 150.0;

    [self drawMenuText:
              @"Try to beat your last time. <esc> exits game.  Use arrow keys for the Hedge Maze."
          font: "Papyrus"
          size: 20
          origin: blurbPoint
          inContext: context
          drawShadow: NO];

    // copyright me!  me me me!
    [self drawMenuText:
              @"  by MarkD.  Copyright 2006 Borkware.  http://borkware.com" 
          font: "Papyrus"
          size: 12.0
          origin: NSMakePoint(5.0, 5.0)
          inContext: context
          drawShadow: NO];

} // drawRect


// change the colors in the color ramp

- (void) throb: (NSTimer *) throb
{
    // for each of the start and end rgb components, move them up or
    // down in value.  If they exceed the ends, turn around and go the
    // other directionx

    int i;
    for (i = 0; i < 3; i++) {

        if (startUp[i]) {
            startRgb[i] = (startRgb[i] + i + 2);
        } else {
            startRgb[i] = (startRgb[i] - (i + 2));
        }
        if (startRgb[i] < 0 || startRgb[i] > 255) {
            startUp[i] = !startUp[i];
        }

        if (endUp[i]) {
            endRgb[i] = (endRgb[i] + i + 3);
        } else {
            endRgb[i] = (endRgb[i] - (i + 3));
        }
        if (endRgb[i] < 0 || endRgb[i] > 255) {
            endUp[i] = !endUp[i];
        }
    }

    [self setNeedsDisplay: YES];

} // throb


// we've been added to the window (or taken away
- (void) viewDidMoveToSuperview
{
    // turn off the timer in case we're being taken out of the windwo

    [throbber invalidate];
    [throbber release];
    throbber = nil;

    // we're going to be visible, so start the ramping of the colors

    if ([self superview] != nil) {
        throbber = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 20.0
                            target: self
                            selector: @selector(throb:)
                            userInfo: NULL
                            repeats: YES];
        [throbber retain];
    }

} // didMoveToSuperview


// these are the games we can play.

- (void) setGameViews: (NSArray *) gv
{
    gameViews = [gv retain];

} // setGameViews


// hit test the given point with the rectangles for the menu titles.
// If there's a hit, that's what the  mouse is over, and so draw
// it highlighted.

- (int) menuUnderMouse: (NSPoint) mouse
{
    int hit = -1; // -1 == no selection

    int i;
    for (i = 0; i < [gameViews count]; i++) {
        BWRaceView *view = [gameViews objectAtIndex: i];

        NSRect rect;
        rect = [self boundsForMenuText: [self nameWithTime: view]
                     font: MENU_FONT
                     size: MENU_SIZE
                     origin: [self originForMenuIndex: i]];

        if (NSPointInRect(mouse, rect)) {
            hit = i;
            break;
        }
    }

    return (hit);

} // menuUnderMouse


// clicky clicky!  

- (void) mouseDown: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]  fromView: nil];

    // this is handy for figuring points in the window for placing
    // graphics stuff.
    // printf ("%f, %f\n", mouse.x, mouse.y);

} // mouseDown


// the user may have selected a menu item.  If so, start the game.

- (void) mouseUp: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]  fromView: nil];
    
    int hit = [self menuUnderMouse: mouse];

    if (hit != -1) {
        [[self controller] swapToView: [gameViews objectAtIndex: hit]];
        selectedMenu = -1;
    }

} // mouseUp


// update the currently selected menu item

- (void) mouseMoved: (NSEvent *) event
{
    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]  fromView: nil];

    int hit = [self menuUnderMouse: mouse];
    
    if (hit != selectedMenu) {
        selectedMenu = hit;
        [self setNeedsDisplay: YES];
    }

} // mouseMoved


// don't want keypresses.

- (BOOL) acceptsFirstResponder
{
    return (NO);
} // acceptsFirstResponder

@end // BWMenuView

