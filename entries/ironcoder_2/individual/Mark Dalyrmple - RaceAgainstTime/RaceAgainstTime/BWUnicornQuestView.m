// Unicorn-catching game

#import "BWUnicornQuestView.h"

#import "AppController.h"
#import "BWTimerView.h"
#import "BWShader.h"

// how big the 'touches the unicorn and it disappears' cursor
#define WHACKER_SIZE 20


@implementation BWUnicornQuestView

// initialize a new game
- (void) omgPONIES
{
    // we're just starting, so we're not done
    done = NO;

    // new game, so we're not a high low-score yet
    isBestTime = NO;

    // number of unicorns to catch
    totalCount = TOTAL_COUNT;

    // use this to figure out where to distribute the critters
    NSRect frame = [self frame];

    // make new unicorns and initial positions for the set that
    // will be drawn.  having 150 on the screen at once is too easy,
    // so add new unicorns (new colors and locations) as old ones
    // are taken off.  Once we fall below the UNICORN_COUNT
    // theshold, then there will be fewer and fewer of them on the
    // screen

    int i;
    for (i = 0; i < UNICORN_COUNT; i++) {
        visible[i] = YES;
        points[i] = NSMakePoint
            (rand() % (int)(frame.size.width - unicornSize.width),
             rand() % (int)(frame.size.height - unicornSize.height));
        
        red[i] = (rand() % 255) / 255.0;
        green[i] = (rand() % 255) / 255.0;
        blue[i] = (rand() % 255) / 255.0;
    }

} // omgPOINES


// get the ball rolling
- (id) initWithFrame: (NSRect) frame  controller: (AppController *) c
{
    if ((self = [super initWithFrame: frame  controller: c])) {

        // get the unicorn image
        NSString *path;
        path = [[NSBundle mainBundle] pathForResource: @"unicorn"
                                      ofType: @"png"];
        unicorn = pngImageAtPath (path);
        unicornSize.width = CGImageGetWidth (unicorn);
        unicornSize.height = CGImageGetHeight (unicorn);

        // create an image mask to clip with
        unicornMask = CGImageMaskCreate(CGImageGetWidth(unicorn),
                                        CGImageGetHeight(unicorn),
                                        CGImageGetBitsPerComponent(unicorn),
                                        CGImageGetBitsPerPixel(unicorn),
                                        CGImageGetBytesPerRow(unicorn),
                                        CGImageGetDataProvider(unicorn),
                                        CGImageGetDecode(unicorn),
                                        CGImageGetShouldInterpolate(unicorn));

        // get the X cursor.
        path = [[NSBundle mainBundle] pathForResource: @"whacker"
                                      ofType: @"png"];
        whackerImage = pngImageAtPath (path);
        assert(whackerImage);
    }

    return (self);

} // initWithFrame


// clean up the mess
- (void) dealloc
{
    CGImageRelease (unicorn);
    CGImageRelease (unicornMask);
    CGImageRelease (whackerImage);

    [super dealloc];

} // dealloc


// draw the stuff
- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    // white background
    [self cleanSlate];

    // run through the unicorn array.  If visible, draw
    int i;
    for (i = 0; i < UNICORN_COUNT; i++) {
        if (!visible[i]) continue;

        // this is the rectangle to draw the unicorn in
        CGRect unirect;
        unirect.origin = cgpoint(points[i]);
        unirect.size = unicornSize;

        CGContextSaveGState(context); {
            // only draw where the mask has 1 bits
            CGContextClipToMask (context, unirect, unicornMask);

            // pour the pain through it
            CGContextSetRGBFillColor (context, red[i], green[i], blue[i], 1.0);
            CGContextFillRect (context, cgrect(unirect));

        } CGContextRestoreGState(context);
    }

    // draw the cursor
    CGRect whackrect;
    whackrect.origin.x = whacker.x - WHACKER_SIZE / 2.0;
    whackrect.origin.y = whacker.y - WHACKER_SIZE / 2.0;
    whackrect.size = CGSizeMake(WHACKER_SIZE, WHACKER_SIZE);
    
    CGContextDrawImage (context, whackrect, whackerImage);

    // tell the player how much is left
    [self drawMenuText: [NSString stringWithFormat: @"%d left", totalCount - 1]
          font: "Papyrus"
          size: 19.0
          origin: NSMakePoint(5.0, 5.0)
          inContext: context
          drawShadow: NO];

    // ++ refactor me - duplicated in hedge game
    if (done) {

        // game is done, tell the user they're exceedingly cool
        NSRect bounds = [self bounds];

        // random tasteless background
        BWShader *shader;
        shader = [BWAxialShader shaderWithStartColor: [NSColor orangeColor]
                                endColor: [NSColor magentaColor]
                                startPoint: NSMakePoint(30.0, 30.0)
                                endPoint: NSMakePoint(bounds.size.width - 30.0,
                                                      bounds.size.height - 30.0)
                                extendStart: YES
                                extendEnd: YES
                                colorSpace: [self rgbColorSpace]];
        [shader drawInContext: context];

        
        // draw WOO
        [self drawMenuText: @"WOOOOOOO!!!"
              font: "Marker Felt Wide"
              size: 100.0
              origin: NSMakePoint(180, 215)
              inContext: context
              drawShadow: NO];

        if (isBestTime) {
            // draw Best Time Evar
            [self drawMenuText: @"Best Score Ever!"
                  font: "Marker Felt Wide"
                  size: 50.0
                  origin: NSMakePoint(270, 165)
                  inContext: context
                  drawShadow: NO];
        }
    }
    // -- refactor me

} // drawRect


- (NSString *) name
{
    //  return (@"Catch the Lesbian Unicorns!");
    return ([NSString stringWithFormat: @"Catch %d Unicorns!", TOTAL_COUNT]);

} // name


// a click ends the 'you won' screen and sends us back to the menu
- (void) mouseUp: (NSEvent *) event
{
    if (done) {
        [controller swapToView: nil];
    }

} // mouseUp


// cause the are where the X cursor is to get redrawn
- (void) invalWhacker: (NSPoint) point
{
    NSRect rect;
    rect.origin.x -= WHACKER_SIZE / 2;
    rect.origin.y -= WHACKER_SIZE / 2;
    rect.size = NSMakeSize(WHACKER_SIZE, WHACKER_SIZE);

    [self setNeedsDisplayInRect: rect];

} // invalWhacker


// we've run out of unicorns.  Stop the timer, if we have a best
// time, hang on to that

- (void) done
{
    [[controller timerView] stop];

    done = YES;
    [NSCursor unhide];

    // don't need the jiggly timer any more
    [timer invalidate];
    [timer release];
    timer = nil;

    // ++ refactor me - copied in hedge game too
    // figure out if this is the BEST GAME EVAR
    int *time = [[controller timerView] minutesSecondsTenths];
    isBestTime = NO;

    if (time[0] < bestTime[0]) {
        isBestTime = YES;
    } else if (time[0] == bestTime[0]) {
        if (time[1] < bestTime[1]) {
            isBestTime = YES;
        } else if (time[1] == bestTime[1]) {
            if (time[2] < bestTime[2]) {
                isBestTime = YES;
            }
        }
    }

    if (isBestTime) {
        int i;
        for (i = 0; i < 3; i++) {
            bestTime[i] = time[i];
        }
        // preserve the best time for all posterity, or at least
        // until RooSwitch makes us a new empty profile.
        [self saveBestTime];
    }
    // -- refactor me

    [self setNeedsDisplay: YES];

} // done


// have we hit a unicorn?  If so, remove it.

- (void) checkHit: (NSPoint) point
{
    // the hit-detection is just bound-boxes, so you can have considered
    // to have hit a unicorn even without touching it.  The game goes
    // by so fast that it's harrd to notice.

    NSRect rect;
    rect.origin.x = point.x - WHACKER_SIZE / 2;
    rect.origin.y = point.y - WHACKER_SIZE / 2;
    rect.size = NSMakeSize(WHACKER_SIZE, WHACKER_SIZE);

    // all unicorns are of uniform size, so pre-create the
    // hit-test rectangle with the size
    NSRect unirect;
    unirect.size = NSMakeSize(unicornSize.width, unicornSize.height);

    // our end-of-game test.  Easier than re-scanning the
    // visible array to see if everyone's gone.
    int visibleCount = 0;

    int i;
    for (i = 0; i < UNICORN_COUNT; i++) {
        if (!visible[i]) continue;

        unirect.origin = points[i];

        NSRect intersect = NSIntersectionRect(unirect, rect);

        // we hit it!
        if (!NSIsEmptyRect(intersect)) {
            totalCount--;

            // !!! play sound, maybe use QTKit since NSSound NSSucks.

            // replace until we're under the max # on the screen
            if (totalCount > UNICORN_COUNT) {
                NSRect frame = [self frame];
                points[i] = NSMakePoint
                    (rand() % (int)(frame.size.width - unicornSize.width),
                     rand() % (int)(frame.size.height - unicornSize.height));

            } else {
                visible[i] = NO;
            }
        }
        if (visible[i]) visibleCount++;
    }

    if (visibleCount == 0) {
        [self done];
    }

} // checkHit


// mouse moved events drive all the action

- (void) mouseMoved: (NSEvent *) event
{
    // if we're not playing, don't do any work
    if (done) return;

    NSPoint mouse;
    mouse = [self convertPoint: [event locationInWindow]  fromView: nil];

    // pin to the view
    mouse.x = MAX(mouse.x, 0.0);
    mouse.x = MIN(mouse.x, [self bounds].size.width);
    mouse.y = MAX(mouse.y, 0.0);
    mouse.y = MIN(mouse.y, [self bounds].size.height);

    [self invalWhacker: whacker];
    whacker = mouse;
    [self invalWhacker: whacker];

    [self checkHit: whacker];

} // mouseMoved


// timer function.  Jiggle the unicorns around to make it a little
// more interesting.  They don't move far, so there's  no checks to 
// make sure they don't go completely off the screen.  lazy lazy lazy

- (void) tick: (NSTimer *) timer
{
    int i;
    for (i = 0; i < UNICORN_COUNT; i++) {
        if (visible[i]) {
            int biasx = random() % 2 ? 1 : -1;
            int biasy = random() % 2 ? 1 : -1;
            
            points[i].x += biasx * (random() % 3);
            points[i].y += biasy * (random() % 3);
        }
    }
    [self setNeedsDisplay: YES];

} // tick


// this tells us when we move to the window or move away.

- (void) viewDidMoveToSuperview
{
    [timer invalidate];
    [timer release];
    timer = nil;

    // we're becoming visible, schedule the timer and start the game

    if ([self superview] != nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 20.0
                         target: self
                         selector: @selector(tick:)
                         userInfo: NULL
                         repeats: YES];
        [timer retain];

        // having the cursor around is kind of ugly, so make it go
        //  away
        [NSCursor hide];

        // populate the game
        [self omgPONIES];

        // and start the timer.  And They're Off!
        [[controller timerView] start];

    } else {
        // we've gone away.  make the cursor appear, and make sure
        // the timer is not timing.
        [NSCursor unhide];
        [[controller timerView] stop];
    }

} // didMoveToSuperview


//  the key to store our low-score in the user prefs.
- (NSString *) bestTimePrefKey
{
    return (@"omgPONIES!");
} // bestTimePrefKey


// the escape key exits the game prematurely.

- (void) keyDown: (NSEvent *) event
{
    NSString *characters;
    characters = [event characters];

    // in case just get dead keys.
    if ([characters length] == 0) return;

    unichar character;
    character = [characters characterAtIndex: 0];

    if (character == 27) {
        [controller swapToView: nil];
    }

} // keyDown


@end // BWUnicornQuestView

