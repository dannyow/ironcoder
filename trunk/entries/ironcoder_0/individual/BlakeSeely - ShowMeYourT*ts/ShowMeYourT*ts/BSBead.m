//
//  BSBead.m
//  ShowMeYourT*ts
//
//  Created by Blake Seely on 3/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSBead.h"
#import "BSShowMeYourConstants.h"


@implementation BSBead

- (id)initWithLocation:(NSPoint)p image:(NSImage *)newImage initialPixelsPerSec:(double)initialPPS initialDegrees:(double)initialDeg necklace:(BSNecklace *)n
{
 
    if (self = [super init]) {
        necklace = n;
        location = p;
        image = [newImage retain];
        speed = initialPPS;
        degrees = initialDeg;
        stopped = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [image release];
    
    [super dealloc];
}

- (NSImage *)image
{
    return image;
}

- (void)setImage:(NSImage *)newImage
{
    if (image != newImage) {
        [newImage retain];
        [image release];
        image = newImage;
    }
}

- (double)speed
{
    return speed;
}

- (void)setSpeed:(double)newSpeed
{
    speed = newSpeed;
}

- (double)degrees
{
    return degrees;
}

- (void)setDegrees:(double)newDegrees
{
    degrees = newDegrees;
}

- (NSPoint)location
{
    return location;
}

- (void)setLocation:(NSPoint)p
{
    location = p;
}

- (BOOL)isStopped
{
    return stopped;
}

- (void)setStopped:(BOOL)stop
{
    stopped = stop;
    speed = kGravityAcceleration;
    degrees = 90;
    [necklace setCaught:stop];
}

@end
