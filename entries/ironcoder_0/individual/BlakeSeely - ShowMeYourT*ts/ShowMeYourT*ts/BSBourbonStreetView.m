#import "BSBourbonStreetView.h"
#import "BSNecklace.h"
#import "BSBead.h"

@implementation BSBourbonStreetView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
    // clear self
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:[self frame]];
    
    if ([[showMeYourAppController necklaces] count] == 0) {
        return;
    }
    
    int i, j;
    
    for (i = 0; i < [[showMeYourAppController necklaces] count]; i++) {
        // first draw the path
        NSBezierPath *p = [NSBezierPath bezierPath];
        [p moveToPoint:[[[[showMeYourAppController necklaces] objectAtIndex:i] beadAtIndex:0] location]];
        for (j = 1; j < [[[showMeYourAppController necklaces] objectAtIndex:i] beadCount]; j++) {
            [p lineToPoint:[[[[showMeYourAppController necklaces] objectAtIndex:i] beadAtIndex:j] location]];
        }
        [p closePath];
        [[NSColor grayColor] set];
        [p setLineJoinStyle:NSBevelLineJoinStyle];
        [p setLineWidth:5.0];
        [p stroke];
        for (j = 0; j < [[[showMeYourAppController necklaces] objectAtIndex:i] beadCount]; j++) {
            BSBead *bead = [[[showMeYourAppController necklaces] objectAtIndex:i] beadAtIndex:j];
            NSPoint loc = [bead location];
            NSImage *image = [bead image];
            loc.x -= ([image size].width) / 2;
            loc.y -= ([image size].height) / 2;
            
            [image drawAtPoint:loc fromRect:NSMakeRect(0,0,[image size].width,[image size].height) operation:NSCompositeSourceOver fraction:1.0];
        }
    }
}

@end
