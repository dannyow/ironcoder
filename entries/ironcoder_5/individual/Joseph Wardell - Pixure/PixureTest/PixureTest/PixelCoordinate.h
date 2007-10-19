//
//  PixelCoordinate.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/31/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
A simple wrapper for x/y coordinates in a PixelPopulation
* doesn't allow unreasonalbe values
* does simple sanity checking
*/
@interface PixelCoordinate : NSObject {
	unsigned int x;
	unsigned int y;
}

+ (PixelCoordinate*)coordinateAtX:(unsigned int)inX y:(unsigned int)inY;

- (id)initWithX:(unsigned int)x y:(unsigned int)y;
- (unsigned int)x;
- (unsigned int)y;

@end
