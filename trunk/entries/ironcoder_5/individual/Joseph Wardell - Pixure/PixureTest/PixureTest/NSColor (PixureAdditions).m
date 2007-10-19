//
//  NSColor (PixureAdditions).m
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "NSColor (PixureAdditions).h"

float randomColorComponent();

float randomColorComponent()
{
	float outRandom = (random() % 1000)/1000.0;
		
	return outRandom;
}

// returns the distance between 2 colors as a float between 0 and sqrt(3)
float distanceBetweenColors(NSColor* baseColor, NSColor* otherColor)
{

    float dhue = fabsf([baseColor hueComponent] - [otherColor hueComponent]);
    float dsat = fabsf([baseColor saturationComponent] -[otherColor saturationComponent]);
    float dbri = fabsf([baseColor brightnessComponent] - [otherColor brightnessComponent]);
    
    float hsbdistance = sqrt(((dhue*dhue) + (dsat*dsat)) + (dbri*dbri)); // pthagorean distance & brightness

	return hsbdistance;
}


@implementation NSColor (PixureAdditions)

+ (NSColor*)randomDeviceColor;
{
	return [NSColor colorWithDeviceRed:randomColorComponent() green:randomColorComponent() blue:randomColorComponent() alpha:1.0];
}

+ (NSColor*)randomGrayDeviceColor;
{
	float randomComponent = randomColorComponent();
	return [NSColor colorWithDeviceRed:randomComponent green:randomComponent blue:randomComponent alpha:1.0];
}

// if necessary, convert the color to the device gray color space
- (NSColor*)deviceRGBColor;
{
	// note: apple's code probably does this anyway, but it's probably just good practice

	if ([NSDeviceRGBColorSpace isEqualToString:[self colorSpaceName]])
		return self;
		
	return [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
}

- (float)distanceFromColor:(NSColor*)compareColor;
{
	return distanceBetweenColors(self, compareColor)/sqrt(3);
}

@end
