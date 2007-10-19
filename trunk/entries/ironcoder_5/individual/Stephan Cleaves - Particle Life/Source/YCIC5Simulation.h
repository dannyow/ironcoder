//
//  YCIC5Simulation.h
//  2D Stars
//
//  Created by Stephan Cleaves on 3/31/07.
//  Copyright 2007 Yellow Camp Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Perhaps have this class act as an enumerator for particles so the view can iterate over them

@interface YCIC5Simulation : NSObject
{
    NSMutableArray *particleArray;
    int width, height, initialParticleCount;
}
- (id)initWithSize:(NSSize)size;
- (void)update;
- (NSEnumerator *)particleEnumerator;
@end
