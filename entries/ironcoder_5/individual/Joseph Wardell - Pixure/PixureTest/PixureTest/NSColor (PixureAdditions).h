//
//  NSColor (PixureAdditions).h
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (PixureAdditions)

// return a random color in the device rgb color space
+ (NSColor*)randomDeviceColor;

// as above, but color is a gray of a certain brightness
+ (NSColor*)randomGrayDeviceColor;

// if necessary, convert the color to the device rgb color space
- (NSColor*)deviceRGBColor;

// return the distance between self and another color as a float between 0 and 1
// note! assumes that both colors are rgb colors and (or else it's dumb) in the same color space
- (float)distanceFromColor:(NSColor*)compareColor;

@end
