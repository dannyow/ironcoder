//
//  BSNecklace.m
//  ShowMeYourT*ts
//
//  Created by Blake Seely on 3/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSNecklace.h"
#import "BSBead.h"
#import "BSShowMeYourConstants.h"


@implementation BSNecklace

- (id)initWithTargetPoint:(NSPoint)target
{
    if (self = [super init]) {        
        caught = NO;
        NSArray *beadImageFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"tiff" inDirectory:@"/beads/"];
        int beadIndex = random() % [beadImageFiles count];
        NSImage *beadImage = [[NSImage alloc] initWithContentsOfFile:[beadImageFiles objectAtIndex:beadIndex]];
        // TODO change the above line so we get random beads
        [beadImage setScalesWhenResized:YES];
        [beadImage setSize:NSMakeSize(16,16)];
        
        beads = [[NSMutableArray alloc] init];
        int i;
        int height = 0.8 * [[NSScreen mainScreen] frame].size.height;
        float startY = random() % (height);
        double heightFraction = startY / [[NSScreen mainScreen] frame].size.height;
        
        for (i = 0; i < kBeadsPerNecklace; i++) {
            double speed = 300.0 + (random() % 40); // varies the speed between beads
            double degrees = (heightFraction * 90) + (random() % 20); // varies the degrees a bit.
            BSBead *newBead = [[BSBead alloc] initWithLocation:NSMakePoint(0,0) image:beadImage initialPixelsPerSec:speed initialDegrees:degrees necklace:self];
            [beads addObject:newBead];
            [newBead release];
        }
        
        for (i = 0; i < kBeadsPerNecklace; i++) {
            double angle = i * (360/kBeadsPerNecklace);
            float x = 20 * cos(angle);
            float y = 20 * sin(angle);
            [[beads objectAtIndex:i] setLocation:NSMakePoint(x-50,y+startY)];
        }
        
    }
    
    return self;
}

- (void)dealloc
{
    [beads release]; 
    
    [super dealloc];
}

- (int)beadCount
{
    return [beads count];
}

- (BSBead *)beadAtIndex:(int)i
{
    return [beads objectAtIndex:i];
}

- (float)maxYPoint
{
    float maxY = -100.0;
    int i;
    for (i = 0; i < [beads count]; i++) {
        NSPoint p = [(BSBead *)[beads objectAtIndex:i] location];
        if (p.y > maxY)
            maxY = p.y;
    }
    return maxY;
}

- (BOOL)isCaught
{
    return caught;
}

- (void)setCaught:(BOOL)catch
{
    caught = catch;
}


@end
