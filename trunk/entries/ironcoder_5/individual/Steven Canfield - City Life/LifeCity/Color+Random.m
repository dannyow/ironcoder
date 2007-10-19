//
//  Color+Random.m
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Color+Random.h"


@implementation NSColor (RandomColorAdditions)
+ (NSColor *)randomColor {
	return [NSColor colorWithCalibratedRed:SSRandomFloatBetween(0.1,1.0) green:SSRandomFloatBetween(0.1,1.0)  blue:SSRandomFloatBetween(0.1,1.0)  alpha:1.0];
}
@end
