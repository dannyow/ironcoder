//
//  YCIC5Simulation.m
//  2D Stars
//
//  Created by Stephan Cleaves on 3/31/07.
//  Copyright 2007 Yellow Camp Software. All rights reserved.
//

#import "YCIC5Simulation.h"
#import "YCIC5Particle.h"

@implementation YCIC5Simulation

- (id)initWithSize:(NSSize)size
{
    if ( ( self = [super init] ) != nil ) {
        int i;
        NSPoint loc;
        
        width = size.width;
        height = size.height;
        initialParticleCount = ( ( width + height ) / 2 ) * 5;
        particleArray = [[NSMutableArray alloc] initWithCapacity:initialParticleCount];
        
        srandomdev();
        for ( i = 0; i < initialParticleCount; i++ ) {
            loc = NSMakePoint( random() % width, random() % height );
            [particleArray addObject:[[[YCIC5Particle alloc] initWithLocation:loc
                velocity:NSZeroPoint] autorelease]];     
        }
    }
    
    return self;
}

- (void)dealloc
{
    [particleArray release]; particleArray = nil;

    [super dealloc];
}

- (void)update
{
    NSEnumerator *particleEnum = [self particleEnumerator];
    YCIC5Particle *particle;
    NSPoint loc, center = NSMakePoint( width / 2, height / 2 );
    
    while ( particle = [particleEnum nextObject] ) {     
        [particle calculateInfluenceOfCenter:center];
        
    }
    
    particleEnum = [self particleEnumerator];
    while ( particle = [particleEnum nextObject] ) {
        loc = [particle location];
        [particle calculateNewLocation];
        loc = [particle location];
        loc.x = fmin( fmax( loc.x, 0 ), width );
        loc.y = fmin( fmax( loc.y, 0 ), height );
        [particle setLocation:loc];
    }
}

- (NSEnumerator *)particleEnumerator
{
    return [particleArray objectEnumerator];
}

@end
