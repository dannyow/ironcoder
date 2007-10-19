//
//  PixelCoordinate.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/31/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PixelCoordinate.h"


@implementation PixelCoordinate

+ (PixelCoordinate*)coordinateAtX:(unsigned int)inX y:(unsigned int)inY;
{
	return [[[PixelCoordinate alloc] initWithX:inX y:inY] autorelease];
}

- (id)initWithX:(unsigned int)inX y:(unsigned int)inY;
{
	if (self = [super init])
	{
		x = inX;
		y = inY;
	}
	return self;
}

- (unsigned int)x;
{
	return x;
}

- (unsigned int)y;
{
	return y;
}


- (BOOL)isEqual:(id)object;
{
	return [self x] == [object x] && [self y] == [object y];
}

- (unsigned)hash
{
	return [[NSArray arrayWithObjects:@"OJW_CheapHashSeed", [NSNumber numberWithUnsignedInt:[self x]], [NSNumber numberWithUnsignedInt:[self y]], nil] hash];
}



@end
