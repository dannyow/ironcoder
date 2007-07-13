#import "BSShowMeYourAppDelegate.h"
#import "BSShowMeYourConstants.h"
#import "BSNecklace.h"
#import "BSBead.h"


@implementation BSShowMeYourAppDelegate

- (id)init
{
    if (self = [super init]) {
        necklaces = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [necklaces release];
    
    [throwTimer invalidate];
    throwTimer = nil;
    
    [locationTimer invalidate];
    locationTimer = nil;
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [window setFrame:[[NSScreen mainScreen] frame] display:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    srandom(time(NULL));
    throwTimer = [NSTimer scheduledTimerWithTimeInterval:kThrowInterval target:self selector:@selector(throwNecklace:) userInfo:nil repeats:YES];
}

- (void)throwNecklace:(NSTimer *)timer
{
    
    BSNecklace *newNecklace = [[BSNecklace alloc] initWithTargetPoint:NSMakePoint(0,0)];
    [necklaces addObject:newNecklace];
    [newNecklace release];
    
    if (nil == locationTimer) {
        locationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateNecklaceLocations:) userInfo:nil repeats:YES];
    }
}

- (void)updateNecklaceLocations:(NSTimer *)timer
{
    int i, j;
    for (i = 0; i < [necklaces count]; i++) {
        for (j = 0; j < [[necklaces objectAtIndex:i] beadCount]; j++) {
            BSNecklace *current = [necklaces objectAtIndex:i];
            int beadCount = [current beadCount];
            int beadIndex = (j + beadCount);
            int leftIndex = (beadIndex - 1) % beadCount;
            int rightIndex = (beadIndex + 1) % beadCount;
            beadIndex = beadIndex % beadCount;
            [self updateBeadVelocity:[current beadAtIndex:beadIndex] basedOnVelocityOfNeighbor1:[current beadAtIndex:leftIndex] neighbor2:[current beadAtIndex:rightIndex]];
            [self updateBeadVelocity:[current beadAtIndex:beadIndex] basedOnDistanceFromNeighbor1:[current beadAtIndex:leftIndex] neighbor2:[current beadAtIndex:rightIndex]];
            [self updateBeadVelocityForGravity:[current beadAtIndex:beadIndex]];
        }
        for (j = 0; j < [[necklaces objectAtIndex:i] beadCount]; j++) {
            [self updateBeadLocationBasedOnVelocity:[[necklaces objectAtIndex:i] beadAtIndex:j]];
        }
    }
    
    for (i = ([necklaces count] - 1); i >= 0; i--) {
        if (0 > [[necklaces objectAtIndex:i] maxYPoint]) {
            [necklaces removeObjectAtIndex:i];
            NSLog(@"Necklaces flew off screen: removing from draw queue. %i left", [necklaces count]);
        }
    }
    
    /* initial testing for behavior when a bead gets caught 
    if ((random() % 100) < 1) {
        if (([necklaces count] > 0) && (![[necklaces objectAtIndex:0] isCaught])) {
            [[[necklaces objectAtIndex:0] beadAtIndex:0] setStopped:YES];
        }
    }
    */
    [bourbonStreetView setNeedsDisplay:YES];
}

- (void)updateBeadVelocity:(BSBead *)bead basedOnVelocityOfNeighbor1:(BSBead *)left neighbor2:(BSBead *)right
{
    if ((![bead isStopped]) && (![left isStopped]) && (![right isStopped])) {
        double yRight = [right speed] * sin(([right degrees] * (M_PI / 180)));
        double yLeft = [left speed] * sin(([left degrees] * (M_PI / 180)));
        double yMiddle = [bead speed] * sin(([bead degrees] * (M_PI / 180)));
        
        double xRight = [right speed] * cos(([right degrees] * (M_PI / 180)));
        double xLeft = [left speed] * cos(([left degrees] * (M_PI / 180)));
        double xMiddle = [bead speed] * cos(([bead degrees] * (M_PI / 180)));
        
        yMiddle += ((((yRight + yLeft) / 2) - yMiddle) / 10);
        xMiddle += ((((xRight + xLeft) / 2) - xMiddle) / 10);
        
        [bead setSpeed:(sqrt((xMiddle * xMiddle) + (yMiddle * yMiddle)))];
        
        // figure out new angle = atan(yfactor / xfactor);
        [bead setDegrees:((atan(yMiddle/xMiddle)) * (180/M_PI))];
    }
}

- (void)updateBeadVelocity:(BSBead *)bead basedOnDistanceFromNeighbor1:(BSBead *)left neighbor2:(BSBead *)right
{
    if (![bead isStopped]) {
        double dyRight = [right location].y - [bead location].y;
        double dxRight = [right location].x - [bead location].x;
        double dRight = sqrt((dyRight * dyRight) + (dxRight * dxRight));
        dRight -= kMaxPixelsBetweenBeads; // acceleration toward right pixel
        dRight *= 0.01; // time slice
        dyRight *= dRight; // y force toward right neighbor
        dxRight *= dRight; // x force toward right neighbor
        if ([left isStopped]) {
            dxRight = dyRight = 0.0;
        }    
        
        double dyLeft = [left location].y - [bead location].y;
        double dxLeft = [left location].x - [bead location].x;
        double dLeft = sqrt((dyLeft *dyLeft) + (dxLeft * dxLeft));
        dLeft -= kMaxPixelsBetweenBeads;
        dLeft *= 0.01; // time slice
        dyLeft *= dLeft;
        dxLeft *= dLeft;
        if ([right isStopped]){
            dxLeft = dyLeft = 0;
        }
        
        double yMiddle = [bead speed] * sin(([bead degrees] * (M_PI / 180)));
        yMiddle += dyLeft + dyRight; // add neighboring forces to my y factor
        double xMiddle = [bead speed] * cos(([bead degrees] * (M_PI / 180)));
        xMiddle += dxLeft + dxRight; // add neighboring forces to my x factor
        
        [bead setSpeed:(sqrt((xMiddle * xMiddle) + (yMiddle * yMiddle)))];
        
        // figure out new angle = atan(yfactor / xfactor);
        [bead setDegrees:((atan(yMiddle/xMiddle)) * (180/M_PI))];
    }
}

- (void)updateBeadVelocityForGravity:(BSBead *)bead
{
    if (![bead isStopped]) {
        float currentX = [bead speed] * cos(([bead degrees] * (M_PI / 180)));
        float currentY = [bead speed] * sin(([bead degrees] * (M_PI / 180)));
        currentY -= (kGravityAcceleration * 0.1);
        
        // friction
        [bead setSpeed:(sqrt((currentX * currentX) + (currentY * currentY)))];
        [bead setDegrees:((atan(currentY/currentX)) * (180/M_PI))];
        
    }
}

- (void)updateBeadLocationBasedOnVelocity:(BSBead *)bead
{
    if (![bead isStopped]) {
        float currentX = [bead speed] * cos(([bead degrees] * (M_PI / 180)));
        float currentY = [bead speed] * sin(([bead degrees] * (M_PI / 180)));
        
        NSPoint loc = [bead location];
        loc.x = loc.x + (currentX * 0.1);
        loc.y = loc.y + (currentY * 0.1);
        //if (loc.y < 0.0) loc.y = 0.0;
        [bead setLocation:loc];
    }    
}

- (NSArray *)necklaces
{
    return necklaces;
}

@end
