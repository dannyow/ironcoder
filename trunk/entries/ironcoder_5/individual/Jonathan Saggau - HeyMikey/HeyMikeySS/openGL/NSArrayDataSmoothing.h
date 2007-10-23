//
//  NSArrayDataSmoothing.h
//  Exercise 20
//
//  Created by Jonathan Saggau on 9/22/06.
//  Copyright 2006 Jonathan Saggau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArrayDataSmoothing)

// Warning::: No err checking here.  Pass it what it wants.
- (NSArray *)movingAverageWithWidth:(int)width;

- (NSArray *)paddedMovingAverageWithWidth:(int)width;

// Warning::: No err checking here.  Pass it what it wants.
- (NSArray *)normalizedArrayToMin:(float) min
                            toMax:(float) max;

    // Returns the first object in the array as sorted with @selector(compare:)
- (id)min;

    // Returns the last object in the array as sorted with @selector(compare:)
- (id)max;
@end