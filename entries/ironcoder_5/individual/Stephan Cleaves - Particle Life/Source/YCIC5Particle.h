//
//  YCIC5Particle.h
//  2D Stars
//
//  Created by Stephan Cleaves on 3/31/07.
//  Copyright 2007 Yellow Camp Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YCIC5Particle : NSObject {
    NSPoint location;
    NSPoint velocity;
    float mass;
}

- (id)initWithLocation:(NSPoint)aPoint velocity:(NSPoint)aVelocity;
- (void)calculateInfluenceOfCenter:(NSPoint)center;
- (void)calculateNewLocation;
- (void)setLocation:(NSPoint)aPoint;
- (NSPoint)location;
- (NSPoint)velocity;
- (float)mass;
@end
