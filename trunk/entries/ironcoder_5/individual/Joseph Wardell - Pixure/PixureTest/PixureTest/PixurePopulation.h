//
//  PixurePopulation.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// PixurePopulation - a 2-dimensional array of pixures, does the generational work of the genetic algorithm      

@class Pixure;
@class PixureSystem;
@class PixelCoordinate;
@class PopulationGeneratedImage;

@interface PixurePopulation : NSObject {
	NSMutableArray* rows;
	unsigned int columnCount;
	
	NSLock* populationLock;
	
	PopulationGeneratedImage* generatedImage;
}

// create a population of a certain size 
- (id)initWithSize:(NSSize)inSize;

// return the pixure at the coordinates passed
- (Pixure*)pixureAtRow:(unsigned int)row column:(unsigned int)column;
- (Pixure*)pixureAtCoordinate:(PixelCoordinate*)inCoordinate;

// return the number of pixtures living
- (unsigned int)numberOfPixures;

- (unsigned int)numberOfRows;
- (unsigned int)numberOfColumns;
- (NSSize)size; // returns the numberOfRows/numberOfColumns as a NSSize for conveninece

// return the maximum numbert of pixures possible - i.e. number of rows * number of columns
- (unsigned int)maximumPixures;

// build an image by creating a bitmap with each pixure producing the color at its assigned coordinates
- (NSImage*)image;

// this is the method where the magic happens
// randomly choose a pixure from the population, and then have it reproduce or compete, depending on the situation
- (void)cycleOnePixureInSystem:(PixureSystem*)inSystem;

/*	the following are from the old way of doing things - not really working, but left for those that may be interested
// thin the herd of pixures,
// remove those that don't match inSystem close enough to [inSystem tolerance]
// replace them with [NSNull null]
// return the number of pixures left
// return whether any had to be removed
- (unsigned int)selectPixuresForSystem:(PixureSystem*)inSystem;

// given a set of coordinates, find the closest remaining pixures that can be bred to produce a new pixure
// fitness for breeding is determined first by closeness and then, if there's a tie, by accuracy to inSystem
- (NSArray*)bestPixuresForRow:(unsigned int)row column:(unsigned int)column inSystem:(PixureSystem*)inSystem;

// for each empty coordinate in the population, create a new pixure by mating two newarby pixures that
// are of high accuracy
- (void)breedNewPixuresForSystem:(PixureSystem*)inSystem;

// if for some reason a coordinate doesn't have a pixure in it, then this algorithm will fail
// to avoid these edge cases, and for first initailization, this method will create a new pixure at any blank coordinate
// whether it's blank because it's never been filled, or just because it's not been populated yet
- (void)createNewPixuresForEmptyCoordinates;
*/

// create a new population of Pixures, filling every pixel
- (void)seedPopulationForFirstTime;

@end
