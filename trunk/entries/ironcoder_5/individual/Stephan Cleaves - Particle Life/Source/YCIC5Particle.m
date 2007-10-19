//
//  YCIC5Particle.m
//  2D Stars
//
//  Created by Stephan Cleaves on 3/31/07.
//  Copyright 2007 Yellow Camp Software. All rights reserved.
//

#import "YCIC5Particle.h"

#define MAX_MASS 50

@implementation YCIC5Particle

- (id)initWithLocation:(NSPoint)aPoint velocity:(NSPoint)aVelocity
{
    if ( ( self = [super init] ) != nil ) {
        [self setLocation:aPoint];
        velocity.x = aVelocity.x;
        velocity.y = aVelocity.y;
        mass = ( random() % 15 ) + 1.0;
    }
    
    return self;

}

- (void)calculateInfluenceOfCenter:(NSPoint)center
{
    double deltaX = center.x - location.x;
    double deltaY = center.y - location.y;
    double distance = hypot( deltaX, deltaY );
    if ( distance < 50 ) distance = 50;
    double velocityAdjust = 0.001 / distance;
    
    velocity.x += velocityAdjust * deltaX;
    velocity.y += velocityAdjust * deltaY;
    velocity.x = fmax( fmin( velocity.x, 1.5 ), -1.5 );
    velocity.y = fmax( fmin( velocity.y, 1.5 ), -1.5 );
}

- (void)calculateNewLocation
{
    location.x += velocity.x;
    location.y += velocity.y;
}

- (void)setLocation:(NSPoint)aPoint
{
    location.x = aPoint.x;
    location.y = aPoint.y;
}

- (NSPoint)location
{
    return location;
}

- (NSPoint)velocity
{
    return velocity;
}

- (float)mass
{
    return mass;
}

@end
