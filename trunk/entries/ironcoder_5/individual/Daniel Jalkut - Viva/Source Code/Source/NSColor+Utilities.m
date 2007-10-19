//
//  NSColor+Utilities.m
//  Viva
//
//  Created by Daniel Jalkut on 9/2/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//

#import "NSColor+Utilities.h"

@implementation NSColor (Utilities)

- (NSColor*) colorByAveragingWithColor:(NSColor*)otherColor
{
	float newRed, newGreen, newBlue, newAlpha;
	newRed = ([self redComponent] + [otherColor redComponent]) / 2;
	newGreen = ([self greenComponent] + [otherColor greenComponent]) / 2;
	newBlue = ([self blueComponent] + [otherColor blueComponent]) / 2;	
	newAlpha = ([self alphaComponent] + [otherColor alphaComponent]) / 2;	
	return [NSColor colorWithDeviceRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@end
