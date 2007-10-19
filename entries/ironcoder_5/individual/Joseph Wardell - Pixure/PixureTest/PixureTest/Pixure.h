//
//  Pixure.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// implementation detail: all colors are represented in device rgb color space

@class PixureSystem;

@interface Pixure : NSObject {
	NSColor* color;
	
//	BOOL adult;
}

// return a pixure that represents the given color:
+ (Pixure*)pixureWithColor:(NSColor*)inColor;

// return a pixure that represents a random color
+ (Pixure*)pixure;

//#warning should be no need to have this in the header
//- (id)initWithColor:(NSColor*)inColor;

// given inPixure, create a new pixure that contains a color that is somewhere between own color and inMate's color
// blend based on the relative strength of each pixure within its environment
// and autorelease the pixure that results for safety
- (Pixure*)pixureByMatingWithPixure:(Pixure*)inMate inPixureSystem:(PixureSystem*)inSystem;

// create a new Pixure that is an asexual descendant of self
// in other words, create a new pixure that is like self, but has one component mutated somehow
// of course, autorelease it
- (Pixure*)pixureByMutating;

// return a float from 0 to 1 that represents how close color is to compareColor, closer values are higher 
- (float)closenessToColor:(NSColor*)compareColor;

// return color, in device color space
- (NSColor*)color;

// return whether this Pixure has survived at least 1 generation
//- (BOOL)isAdult;

// called by the PixurePopulation to let the Pixure know that it has survived its first generation
//- (void)mature;

@end
