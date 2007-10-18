// Some links that might help out:

// intro:
// http://developer.apple.com/macosx/coreimage.html

// Programming Guide
// http://developer.apple.com/documentation/GraphicsImaging/Conceptual/CoreImaging/index.html

// Reference
// http://developer.apple.com/documentation/GraphicsImaging/Reference/CoreImagingRef/index.html
// The Core Image Fun House is useful for figuring out what the parameters to
// the filters are.

// Samples:
// /Developer/Examples/Quartz/Core\ Image

// Filter Reference:
// http://developer.apple.com/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html

// You'll need to add the Quartz Core framework to your project to make the linker
// happy.

#import "BWSpaceView.h"

// Obligatory bunch of constants

// How big to make the text
#define TEXT_SIZE 40.0f

// How much to change the space on each timer fire.
#define SPACE_INCREMENT 1.0f

// How often to fire the timer
#define FRAME_RATE (1.0f / 20.0f)

// Constraints for the size of the space.
#define MAX_SPACE 200.0f
#define MIN_SPACE 120.0f

// The initial space size.
#define SPACE MIN_SPACE

// Size of the unicorn.  I probably could have gotten it from the image,
// but I'm lazy
#define IMAGE_WIDTH 432
#define IMAGE_HEIGHT 436

// The size (large) and scale (make it pinchy) for the distortion bump.
#define BUMP_RADIUS 150.0f
#define BUMP_SCALE -1.0f

// Initial vector for the distortion bump.
#define BUMP_X_INCREMENT 1.0f
#define BUMP_Y_INCREMENT -3.0f



@implementation BWSpaceView

- (void) setUpCoreImageJazz
{
    // Get our Unicorn.
    NSString *path = [[NSBundle mainBundle] pathForResource: @"unicorn"
                                            ofType: @"jpg"];
    NSURL *url = [NSURL fileURLWithPath: path];
    
    // Make a CI Image out of it - this will be the input image for
    // the filter chain.
    CIImage *lesbianUnicorn;
    lesbianUnicorn = [CIImage imageWithContentsOfURL:  url];

    // Initial position of the bump.
    CIVector *bumpPoint;
    bumpPoint = [CIVector vectorWithX: bumpX
                          Y: bumpY];

    // Make a Bump distortion filter, giving it the unicorn for the
    // input, and specifying initial values for stuff.

    filter = [CIFilter filterWithName: @"CIBumpDistortion"
                       keysAndValues: 
                       @"inputImage", lesbianUnicorn, 
                       @"inputRadius", [NSNumber numberWithFloat: BUMP_RADIUS],
                       @"inputScale", [NSNumber numberWithFloat: BUMP_SCALE],
                       @"inputCenter", bumpPoint,
                       nil];
    [filter retain];

} // setUpCoreImageJazz


- (id) initWithFrame: (NSRect)frame
{
    if ((self = [super initWithFrame: frame])) {
        words = [[NSArray alloc]
                    initWithObjects:@"#macsb", @"iron", @"coder", @"rocks!!", 
                    nil];
        space = SPACE;
        spaceIncrement = SPACE_INCREMENT;
        
        textAttributes = [[NSDictionary alloc]
                             initWithObjectsAndKeys:
                                 [NSFont fontWithName: @"Marker Felt"
                                         size: TEXT_SIZE],
                             NSFontAttributeName,
                             nil];

        // Start the bump in the middle
        bumpX = IMAGE_WIDTH / 2.0;
        bumpY = IMAGE_WIDTH / 2.0;

        bumpXincrement = BUMP_X_INCREMENT;
        bumpYincrement = BUMP_Y_INCREMENT;

        [self setUpCoreImageJazz];
    }
  
    return (self);

} // initWithFrame


- (void) dealloc
{
    [textAttributes release];

    [timer invalidate];
    [timer release];

    [filter release];

    [super dealloc];

} // dealloc


- (void) drawTextCenteredAtPoint: (NSPoint) center
{
    // Figure out total length of the string so we can center it.
    float length = ([words count] - 1) * space;

    unsigned count = [words count];

    unsigned i;
    for (i = 0; i < count; i++) {
        NSString *word = [words objectAtIndex: i];
    
        length += [word sizeWithAttributes: textAttributes].width;
    }

    NSPoint point = center;
    point.x -= length / 2.0f;

    // Now loop through words, drawing words.  The caller can set up
    // any transforms (like rotation or scaling) before-hand.

    for (i = 0; i < count; i++) {

        // Get the next word and draw it.
        NSString *word = [words objectAtIndex: i];
        [word drawAtPoint: point
              withAttributes: textAttributes];

        // Move to the end of the word
        point.x += [word sizeWithAttributes: textAttributes].width;

        // Draw a unicorn, but only between words
        if (i < (count - 1)) {

            // The fudge factor for point.y is to kind of get the unicorn
            // centered with the text.  I really should have dug into the
            // font metrics.  But hey, I'm lazy.

            CGRect unicornRect = CGRectMake(point.x, 
                                            point.y - space / 2.0 + TEXT_SIZE / 2.0,
                                            space, space);
            
            // Get the CI Context so we can draw.
            CIContext* context = [[NSGraphicsContext currentContext] CIContext];

            // Draw the critter.
            [context drawImage: [filter valueForKey: @"outputImage"]
                     inRect: unicornRect
                     fromRect: CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
        }

        // And skip over the 'space'.
        point.x += space;
    }

} // drawText


- (void) drawRect: (NSRect)rect
{
    NSRect bounds = [self bounds];

    [[NSColor whiteColor] set];
    NSRectFill (bounds);
  
    NSPoint center;
    center = NSMakePoint (bounds.size.width / 2.0f,
                          bounds.size.height / 2.0f);

    [self drawTextCenteredAtPoint: center];

    [[NSColor blackColor] set];
    NSFrameRect (bounds);

} // drawRect


- (void) tick: (NSTimer *) timer
{
    space += spaceIncrement;

    if (space > MAX_SPACE || space < MIN_SPACE) {
        spaceIncrement = -spaceIncrement;
    }


    CIVector *bumpPoint;
    bumpPoint = [CIVector vectorWithX: bumpX
                          Y: bumpY];
    [filter setValue: bumpPoint
            forKey: @"inputCenter"];

    bumpX += bumpXincrement;
    if (bumpX > IMAGE_WIDTH || bumpX < 0) {
        bumpX = IMAGE_WIDTH / 2.0;
        bumpXincrement = -bumpXincrement;
    }

    bumpY += bumpYincrement;
    if (bumpY > IMAGE_WIDTH || bumpY < 0) {
        bumpY = IMAGE_HEIGHT / 2.0;
        bumpYincrement = -bumpYincrement;
    }

    if ((random() % 120) == 0) {
        bumpXincrement = -bumpXincrement;
    }
    if ((random() % 120) == 0) {
        bumpYincrement = -bumpYincrement;
    }


    [self setNeedsDisplay: YES];

} // tick

- (void) awakeFromNib
{
    timer = [NSTimer scheduledTimerWithTimeInterval: FRAME_RATE
                     target: self
                     selector: @selector(tick:)
                     userInfo: nil
                     repeats: YES];
    [timer retain];

} // awakeFromNib

@end // BWSpaceView

