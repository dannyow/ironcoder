//
//  PixurePopulation.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PixurePopulation.h"
#import "PixureSystem.h"
#import "Pixure.h"
#import "PixelCoordinate.h"
#import "PopulationmGeneratedImage.h"


@implementation PixurePopulation

- (id)initWithSize:(NSSize)inSize;
{
	if ((self = [super init]) != nil)
	{
		rows = [[NSMutableArray alloc] initWithCapacity:inSize.height];
		columnCount = inSize.width;
		unsigned int i;	for (i = 0; i < inSize.height; i++) 
		{
			NSMutableArray* thisRow = [[NSMutableArray alloc] initWithCapacity:columnCount];
			unsigned int j;	for (j = 0; j < inSize.width; j++) 
			{
				[thisRow addObject:[NSNull null]];
			}
			[rows addObject:thisRow];
			[thisRow release];
		}
		populationLock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[rows release];
	[populationLock release];
	[generatedImage release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Private Accessors

- (NSMutableArray*)rows;
{
	if (nil == rows)
		rows = [[NSMutableArray alloc] init];
		
	return rows;
}

#pragma mark -
#pragma mark Private Image Management

- (void)_clearCachedImage;
{
//#warning need to replace this with a call to update the image instead
//	if (nil == lastPicture)
//		return; // no need to do anything
//
//	[lastPicture release];
//	lastPicture = nil;

	[generatedImage clear];

}



#pragma mark -
#pragma mark Accessors

- (Pixure*)pixureAtRow:(unsigned int)row column:(unsigned int)column;
{
	if (row > [self numberOfRows] - 1)
		return nil;
	if (column > [self numberOfColumns] - 1)
		return nil;

	[populationLock lock];
	id outPixure = [[[self rows] objectAtIndex:row] objectAtIndex:column];
	[populationLock unlock];

	if ([outPixure isEqualTo:[NSNull null]])
		return nil;
		
	return [[outPixure retain] autorelease];
}

- (BOOL)containsCoordinate:(PixelCoordinate*)inCoordinate;
{
	return [inCoordinate x] < [self numberOfColumns] && [inCoordinate y] < [self numberOfRows];
}

- (Pixure*)pixureAtCoordinate:(PixelCoordinate*)inCoordinate;
{
	return [self pixureAtRow:[inCoordinate y] column:[inCoordinate x]];
}

// return yes if coordinates are valid (inside pixel space) and empty (no pixure living there)
- (BOOL)coordinatesAreEmpty:(PixelCoordinate*)inCoordinate;
{
	if (![self containsCoordinate:inCoordinate])
		return NO;
		
	return nil == [self pixureAtCoordinate:inCoordinate];
}

- (NSArray*)validNeighboringCoordinatesToCoordinate:(PixelCoordinate*)inCoordinate;
{
	NSMutableArray* outCoordinates = [NSMutableArray arrayWithCapacity:8];
	unsigned int i;	for (i = [inCoordinate x] - 1; i <= [inCoordinate x] + 1; i++) 
	{
		unsigned int j;	for (j = [inCoordinate y] - 1; j <= [inCoordinate y] + 1; j++) 
		{
			PixelCoordinate* coord = [PixelCoordinate coordinateAtX:i y:j];
			if ([self containsCoordinate:coord] && ![inCoordinate isEqual:coord])
				[outCoordinates addObject:coord];
		}
	}
	return outCoordinates;
}

- (NSArray*)emptyCoordinatesNearCoordinate:(PixelCoordinate*)inCoordinate;
{
	NSMutableArray* outCoordinates = [NSMutableArray arrayWithCapacity:8];
	NSEnumerator *enumerator = [[self validNeighboringCoordinatesToCoordinate:inCoordinate] objectEnumerator];
	PixelCoordinate*thisCoord;

	while ((thisCoord = [enumerator nextObject]) != nil) 
	{
		if ([self coordinatesAreEmpty:thisCoord])
			[outCoordinates addObject:thisCoord];
	}
	return outCoordinates;
}

- (NSArray*)occupiedCoordinatesNearCoordinate:(PixelCoordinate*)inCoordinate;
{
	NSMutableArray* outCoordinates = [NSMutableArray arrayWithCapacity:8];
	NSEnumerator *enumerator = [[self validNeighboringCoordinatesToCoordinate:inCoordinate] objectEnumerator];
	PixelCoordinate*thisCoord;

	while ((thisCoord = [enumerator nextObject]) != nil) 
	{
		if (![self coordinatesAreEmpty:thisCoord])
			[outCoordinates addObject:thisCoord];
	}
	return outCoordinates;
}

- (NSSize)size;
{	
	return NSMakeSize([self numberOfColumns],[self numberOfRows]);
}

- (unsigned int)numberOfRows;
{
	[populationLock lock];
	unsigned int outRows = [[self rows] count];
	[populationLock unlock];
	return outRows;
}

- (unsigned int)numberOfColumns;
{
	return columnCount;
}

- (unsigned int)maximumPixures;
{
	return [self numberOfRows] * [self numberOfColumns];
}

#pragma mark -
#pragma mark Generated Image



- (NSImage*)image;
{
	if (![self numberOfRows])
		return nil;

	if (nil == generatedImage)
		generatedImage = [[PopulationGeneratedImage alloc] initWithPopulation:self];
	return [generatedImage image];
}

#pragma mark -
#pragma mark Pixure Collection Accessors

- (unsigned int)numberOfPixures;
{
	unsigned int outCount = 0;

	unsigned int i;	for (i = 0; i < [self numberOfRows]; i++) 
	{
		unsigned int j;	for (j = 0; j < [self numberOfColumns]; j++) 
		{
			if (nil != [self pixureAtRow:i column:j])
				outCount++;
		}
	}	
	return outCount;
}

- (BOOL)_mustCreateNewPixures;
{
	return (([self maximumPixures] - [self numberOfPixures]) > 0);
}

- (unsigned int)randomRow;
{
	return random() % [self numberOfRows];
}

- (unsigned int)randomColumn;
{
	return random() % [self numberOfColumns];
}

- (Pixure*)randomPixureWithTimeout:(unsigned int)inMaxTries;
{
	// note! ideally, we'd only find pixures that had survived a generation before doing this, but for now...
	// not a great algorithm, does not consider place at all, quickly generates to gray after a dozen or so generations

	Pixure* outPixure = nil;
	
	while (nil == outPixure && inMaxTries-- > 0)
	{
		outPixure = [self pixureAtRow:[self randomRow] column:[self randomColumn]];
		if ([outPixure isEqualTo:[NSNull null]])
			outPixure = nil;
	}
	return outPixure;
}

- (Pixure*)randomPixure;
{
	return [self randomPixureWithTimeout:100];
}


#pragma mark -
#pragma mark Pixure Life Cycle


- (void)killPixureAtRow:(unsigned int)row column:(unsigned int)column;
{
	[[[self rows] objectAtIndex:row] replaceObjectAtIndex:column withObject:[NSNull null]];
}

- (void)addPixure:(Pixure*)inPixure atRow:(unsigned int)row column:(unsigned int)column;
{
	[[[self rows] objectAtIndex:row] replaceObjectAtIndex:column withObject:inPixure];
}

- (void)newPixureAtRow:(unsigned int)row column:(unsigned int)column;
{
	[self addPixure:[Pixure pixure] atRow:row column:column];
}

#pragma mark -
#pragma mark Real Work


- (void)cycleOnePixureInSystem:(PixureSystem*)inSystem;
{
	if (![self numberOfRows])
		return;

	// find a pixure to use
	Pixure* thisPixure = nil;
	int maxTries = 100;
	unsigned int thisRow, thisColumn;
	while (nil == thisPixure && maxTries-- > 0)
	{
		thisRow = [self randomRow];
		thisColumn = [self randomColumn];
		thisPixure = [self pixureAtRow:thisRow column:thisColumn];
		if ([thisPixure isEqualTo:[NSNull null]])
			thisPixure = nil;
	}
	if (nil == thisPixure)
		return;

	PixelCoordinate* startCoordinates = [PixelCoordinate coordinateAtX:thisColumn y:thisRow];

	// collect coordinates to change so we can update the image at the end
	NSMutableArray* changedCoordinates = [NSMutableArray array];
		
	NSColor* sourceColor = [[inSystem sourceImage] colorAtX:thisColumn y:thisRow];
	if (![sourceColor alphaComponent])
	{
		[self killPixureAtRow:thisRow column:thisColumn];
		[generatedImage addCoordinatesToUpdateQueue:[NSArray arrayWithObject:startCoordinates]];
		return;
	}

	NSArray* emptyCoordinates = [self emptyCoordinatesNearCoordinate:startCoordinates];
	if ([emptyCoordinates count])
	{
		// there are available empty coordinates
		// choose one where we'll reproduce
		PixelCoordinate* newCoordinate = [emptyCoordinates objectAtIndex:random() % [emptyCoordinates count]];
		Pixure* newPixure = [thisPixure pixureByMutating];
		[self addPixure:newPixure atRow:[newCoordinate y] column:[newCoordinate x]];
		[changedCoordinates addObject:newCoordinate];
	}
	else
	{
		// all local coordinates are full, have to compete
		NSArray* fullCoordinates = [self occupiedCoordinatesNearCoordinate:startCoordinates];
		NSEnumerator *enumerator = [fullCoordinates objectEnumerator];
		PixelCoordinate* thisCoordinate;
		
		float accuracy = [thisPixure closenessToColor:sourceColor];
		BOOL wonOne = NO;
		while ((thisCoordinate = [enumerator nextObject]) != nil) 
		{
			Pixure* otherPixure = [self pixureAtCoordinate:thisCoordinate];
			if (!otherPixure)
				continue;
			
			NSColor* otherColor = [[inSystem sourceImage] colorAtX:[thisCoordinate x] y:[thisCoordinate y]];
			float otherAccuracy = [otherPixure closenessToColor:otherColor];
			
			if (otherAccuracy < accuracy)
			{
				[self killPixureAtRow:[thisCoordinate y] column:[thisCoordinate x]];
				wonOne = YES;
				[changedCoordinates addObject:thisCoordinate];
			}
		}
		
		// if couldn't beat any neighboring pixure, but not yet 100% accurate, then die
		if (!wonOne && accuracy < 1.0)
		{
			[self killPixureAtRow:thisRow column:thisColumn];
			[changedCoordinates addObject:startCoordinates];
		}
	}
	
	[generatedImage addCoordinatesToUpdateQueue:changedCoordinates];	
}


// if for some reason a coordinate doesn't have a pixure in it, then this algorithm will fail
// to avoid these edge cases, and for first initailization, this method will create a new pixure at any blank coordinate
// whether it's blank because it's never been filled, or just because it's not been populated yet
- (void)createNewPixuresForEmptyCoordinates;
{
	if (![self _mustCreateNewPixures])
	{
		return;
	}

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	unsigned int i;	for (i = 0; i < [self numberOfRows]; i++) 
	{
		unsigned int j;	for (j = 0; j < [self numberOfColumns]; j++) 
		{
			[self newPixureAtRow:i column:j];
		}
	}

	[pool release];

	[generatedImage clear];
}


- (void)seedPopulationForFirstTime;
{
	[self createNewPixuresForEmptyCoordinates];
	[generatedImage clear];
	return;

//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//
//	unsigned int i;	for (i = 0; i < [self numberOfRows]; i++) 
//	{
//		unsigned int j;	for (j = 0; j < [self numberOfColumns]; j++) 
//		{
//			[self addPixure:[Pixure pixureWithColor:[NSColor grayColor]] atRow:i column:j];
//		}
//	}
//
//	[pool release];
//
//	[generatedImage clear];
}


/*
// thin the herd of pixures,
// remove those that don't match inSystem close enough to [inSystem tolerance]
// replace them with [NSNull null]
// return the number of pixures removed
- (unsigned int)selectPixuresForSystem:(PixureSystem*)inSystem;
{
	float tolerance = [inSystem tolerance];
	unsigned int removed = 0;
	
	unsigned int i;	for (i = 0; i < [[self rows] count]; i++) 
	{
		NSMutableArray* thisRow = [[self rows] objectAtIndex:i];
		unsigned int j;	for (j = 0; j < [thisRow count]; j++) 
		{
			Pixure* thisPixure = [self pixureAtRow:i column:j];
			if (nil == thisPixure)
				continue;

			NSColor* sourceColor = [[inSystem sourceImage] colorAtX:j y:i];
			if (([sourceColor alphaComponent] < 1.0) || ([thisPixure closenessToColor:sourceColor] < (1.0 - tolerance)))
			{
				[thisRow replaceObjectAtIndex:j withObject:[NSNull null]];
				removed++;
			}
			else
			{
				[thisPixure mature]; // if it wasn't before, it's now ready to reproduce
			}
		}
	}
	
	if (removed)
		[self _clearCachedImage];
		
	return removed;
}


- (Pixure*)randomParentPixureWithin:(unsigned int)inDelta pixelsOfRow:(unsigned int)inRow column:(unsigned int)inColumn withTimeout:(unsigned int)inMaxTries;
{
	// note! ideally, we'd only find pixures that had survived a generation before doing this, but for now...

	Pixure* outPixure = nil;
	unsigned int triesLeft = inMaxTries;
	while ((nil == outPixure) && (triesLeft-- > 0))
	{
		unsigned int row = inRow + ((random() % inDelta) * (random() % 2 ? -1 : 1));
		unsigned int column = inColumn + ((random() % inDelta) * (random() % 2 ? -1 : 1));
		outPixure = [self pixureAtRow:row column:column];
		if ([outPixure isEqualTo:[NSNull null]] || ![outPixure isAdult])
			outPixure = nil;
	}	
	return outPixure;
}

// given a set of coordinates, find the closest remaining pixures that can be bred to produce a new pixure
// fitness for breeding is determined first by closeness and then, if there's a tie, by accuracy to inSystem
- (NSArray*)bestPixuresForRow:(unsigned int)row column:(unsigned int)column inSystem:(PixureSystem*)inSystem;
{
#warning suboptimal, but a simple way to produce sexual reproduction among colors (ooh la la)

	// start with closest and keep looking until we find one that works
	unsigned int delta = 1;
	Pixure* firstPixure = nil;
	while (nil == firstPixure && delta < 100) // delta < 100 for sanity's sake
		firstPixure = [self randomParentPixureWithin:delta++ pixelsOfRow:row column:column withTimeout:(delta + 1) * (delta + 1)]; // note! - not an exhaustive search

	Pixure* secondPixure = nil;
	while (nil == secondPixure && secondPixure != firstPixure && delta < 100)
		secondPixure = [self randomParentPixureWithin:delta++ pixelsOfRow:row column:column withTimeout:(delta + 1) * (delta + 1)]; // note! - not an exhaustive search

	return [NSArray arrayWithObjects:firstPixure, secondPixure, nil];

//#warning incomplete
//	return [NSArray array];
}

- (Pixure*)parentForNewPixureAtRow:(unsigned int)row column:(unsigned int)column
{
	unsigned int delta = 1;
	Pixure* firstPixure = nil;
	while (nil == firstPixure && delta < 32) // delta < 100 for sanity's sake
		firstPixure = [self randomParentPixureWithin:delta++ pixelsOfRow:row column:column withTimeout:(delta * 2) * (delta * 2)]; // note! - not an exhaustive search

	return firstPixure;
}

// for each empty coordinate in the population, create a new pixure by mating two nearby pixures that
// are of high accuracy
- (void)breedNewPixuresForSystem:(PixureSystem*)inSystem;
{
	if (![self _mustCreateNewPixures])
	{
		NSLog(@"don't need to create any pixures");
			return;
	}

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	unsigned int i;	for (i = 0; i < [[self rows] count]; i++) 
	{
		NSMutableArray* thisRow = [[self rows] objectAtIndex:i];
		unsigned int j;	for (j = 0; j < [thisRow count]; j++) 
		{
			Pixure* foundParent = [self parentForNewPixureAtRow:i column:j];
			if (nil != foundParent)
			{
				Pixure* newPixure = [foundParent pixureByMutating];
				if (nil != newPixure)
					[thisRow replaceObjectAtIndex:j withObject:newPixure];
			}
		
//			NSArray* foundParents = [self bestPixuresForRow:i column:j inSystem:inSystem];
//			if ([foundParents count] > 1) // just to be safe
//			{
//				// this approach is very slow because blendedColorWithFraction: is very slow, so I just use 
//				//Pixure* newPixure = [[foundParents objectAtIndex:0] pixureByMatingWithPixure:[foundParents objectAtIndex:1] inPixureSystem:inSystem];
//				Pixure* newPixure = [[foundParents objectAtIndex:0] pixureByMutating];
//				if (nil != newPixure)
//					[thisRow replaceObjectAtIndex:j withObject:newPixure];
//				//NSLog(@"replacing object at %@", NSStringFromPoint(NSMakePoint(j, i)));
//			}
		}
	}

	[pool release];

	[self _clearCachedImage];
}
*/




@end
