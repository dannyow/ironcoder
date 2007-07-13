//
//  BSBead.h
//  ShowMeYourT*ts
//
//  Created by Blake Seely on 3/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BSNecklace.h"


@interface BSBead : NSObject {
    NSImage *image;
    BSNecklace *necklace;
    double speed;
    double degrees;
    NSPoint location;
    BOOL stopped;
}

- (id)initWithLocation:(NSPoint)p image:(NSImage *)image initialPixelsPerSec:(double)initialPPS initialDegrees:(double)initialDeg necklace:(BSNecklace *)n;

- (NSImage *)image;
- (void)setImage:(NSImage *)image;
- (double)speed;
- (void)setSpeed:(double)newSpeed;
- (double)degrees;
- (void)setDegrees:(double)newDegrees;
- (NSPoint)location;
- (void)setLocation:(NSPoint)p;
- (BOOL)isStopped;
- (void)setStopped:(BOOL)stop;


@end
