//
//  Pixure.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "Pixure.h"
#import "NSColor (PixureAdditions).h"
#import "OJW_PixureSaverDefaults.h"

@implementation Pixure

+ (void)initialize;
{
	srandom(floor([NSDate timeIntervalSinceReferenceDate]));
}

// return a pixure that represents the given color:
+ (Pixure*)pixureWithColor:(NSColor*)inColor;
{
	return [[[Pixure alloc] initWithColor:inColor] autorelease];
}

// return a pixure that represents a random color
+ (Pixure*)pixure;
{
	switch ([[OJW_PixureSaverDefaults OJW_PixureSaverDefaults] typeOfNewPixure])
	{
		case 0: // random grayscale
			return [Pixure pixureWithColor:[NSColor randomGrayDeviceColor]];
			break;
		case 1: // random color
			return [Pixure pixureWithColor:[NSColor randomDeviceColor]];
			break;
		case 2: // neutral grayscale
			return [Pixure pixureWithColor:[NSColor colorWithDeviceHue:0 saturation:0 brightness:0.5 alpha:1.0]];
			break;
		case 3: // clear color
			return [Pixure pixureWithColor:[NSColor clearColor]];
			break;
	}

	return [Pixure pixureWithColor:[NSColor randomGrayDeviceColor]];
}

#pragma mark -
#pragma mark Private Accessors

- (void)setColor:(NSColor*)inColor;
{
	inColor = [inColor deviceRGBColor];

	if ([[self color] isEqualTo:inColor])
		return;

	[inColor retain];
	[color release];
	color = inColor;
}



#pragma mark -
#pragma mark init



- (id)initWithColor:(NSColor*)inColor;
{
	if ((self = [super init]) != nil) {
		[self setColor:inColor];
//		adult = NO;
	}
	return self;
}

- (void)dealloc
{
	[color release];

	[super dealloc];
}


#pragma mark -
#pragma mark Genetic Algorithm

+ (NSColor*)mutatedColorFromColor:(NSColor*)inColor;
{
	// only mutate half the time
	if (random() % 2)
		return inColor;

	float mutationRate = 0.25;

	float newRed = [inColor redComponent];
	float newGreen = [inColor greenComponent];
	float newBlue = [inColor blueComponent];
	float mutation = (mutationRate * ((random() % 2) ? 1.0 : -1.0));
	switch (random() % 3)
	{
		case 0:
			newRed = newRed + mutation;
			break;
		case 1:
			newGreen = newGreen + mutation;
			break;
		case 2:
			newBlue = newBlue + mutation;
			break;
	}

	return [NSColor colorWithDeviceRed:newRed green:newGreen blue:newBlue alpha:1.0];
}

// given inPixure, create a new pixure that contains a color that is somewhere between own color and inMate's color
// blend based on the relative strength of each pixure within its environment
// and autorelease the pixure that results for safety
- (Pixure*)pixureByMatingWithPixure:(Pixure*)inMate inPixureSystem:(PixureSystem*)inSystem;
{
	// no longer used in code, but I'll keep it here for those who are curious...
	// blendedColorWithFraction: ended up being a real bottleneck for some reason that I know would take a day to track down...

	NSColor* newColor = [[self color] blendedColorWithFraction:0.5 ofColor:[inMate color]];

	return [Pixure pixureWithColor:[[self class] mutatedColorFromColor:newColor]];
}

// create a new Pixure that is an asexual descendant of self
// in other words, create a new pixure that is like self, but has one component mutated somehow
// of course, autorelease it
- (Pixure*)pixureByMutating;
{
	return [Pixure pixureWithColor:[[self class] mutatedColorFromColor:[self color]]];
}


#pragma mark -
#pragma mark Accessors


// return color, in device color space
- (NSColor*)color;
{ 
	return [[color retain] autorelease]; 
}

// return a float from 0 to 1 that represents how close color is to compareColor, closer values are higher 
- (float)closenessToColor:(NSColor*)compareColor;
{
	// note: I'm assuming a device rgb color space, so other color spaces may crash here...

	return 1.0 - [[self color] distanceFromColor:compareColor];

//#warning WRONG!
//	return 0.5;
}

// return whether this Pixure has survived at least 1 generation
//- (BOOL)isAdult;
//{
//	return adult;
//}
//
//- (void)mature;
//{
//	adult = YES;
//}

@end
