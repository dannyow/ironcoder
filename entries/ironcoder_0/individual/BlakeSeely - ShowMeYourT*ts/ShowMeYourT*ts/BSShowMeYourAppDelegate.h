/* BSShowMeYourAppDelegate */

#import <Cocoa/Cocoa.h>
#import "BSBead.h"

@interface BSShowMeYourAppDelegate : NSObject {
    IBOutlet NSView *bourbonStreetView;
    IBOutlet NSMutableArray *necklaces;
    IBOutlet NSWindow *window;
    
    NSTimer *throwTimer;
    NSTimer *locationTimer;
}

- (NSArray *)necklaces;

- (void)throwNecklace:(NSTimer *)timer;
- (void)updateNecklaceLocations:(NSTimer *)timer;

- (void)updateBeadVelocity:(BSBead *)bead basedOnVelocityOfNeighbor1:(BSBead *)left neighbor2:(BSBead *)right;
- (void)updateBeadVelocity:(BSBead *)bead basedOnDistanceFromNeighbor1:(BSBead *)left neighbor2:(BSBead *)right;
- (void)updateBeadVelocityForGravity:(BSBead *)bead;
- (void)updateBeadLocationBasedOnVelocity:(BSBead *)bead;


@end
