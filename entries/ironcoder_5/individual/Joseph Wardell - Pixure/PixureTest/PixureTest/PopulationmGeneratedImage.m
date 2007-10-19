//
//  PopulationmGeneratedImage.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/31/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PopulationmGeneratedImage.h"
#import "PixurePopulation.h"
#import "PixelCoordinate.h"

@interface PopulationGeneratedImage (PRIVATE)

- (NSMutableArray*)updateQueue;
- (PixurePopulation*)population;

@end

#pragma mark -

@implementation PopulationGeneratedImage

- (id)initWithPopulation:(PixurePopulation*)inPopulation;
{
	if ((self = [super init]) != nil) {
		[self setPopulation:inPopulation];
		pictureLock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[updateQueue release];
	[lastPicture release];
//	[population release];

	[pictureLock release];

	[super dealloc];
}


#pragma mark -
#pragma mark Image Manipulation

- (NSImage*)generateImage;
{
	[pictureLock lock];

	int w = [[self population] size].width;
	int h = [[self population] size].height;

	NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize(w,h)] autorelease];
    NSBitmapImageRep *destImageRep = [[[NSBitmapImageRep alloc] 
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:w 
                    pixelsHigh:h 
                    bitsPerSample:8 
                    samplesPerPixel:3
                    hasAlpha:NO
                    isPlanar:NO
                    colorSpaceName:NSDeviceRGBColorSpace
                    bytesPerRow:0 
                    bitsPerPixel:0] autorelease];

	unsigned int i;	for (i = 0; i < [[self population] numberOfRows]; i++) 
	{
		unsigned int j;	for (j = 0; j < [[self population] numberOfColumns]; j++) 
		{
			Pixure* thisPixure = [[self population] pixureAtRow:i column:j];
			if (nil == thisPixure)
				continue;
					
			[destImageRep setColor:[thisPixure color] atX:j y:[[self population] size].height - i];
			
		}
	}
	

	[pictureLock unlock];

    [newImage addRepresentation:destImageRep];

	return newImage;
}


- (void)updateImageAtCoordinates:(NSArray*)inCoordinatesToUpdate;
{
	// make sure that we actually have the picture...
	if (nil == lastPicture)
		[self image];
	if (nil == lastPicture)
		return; // if still can't, then just bail

    NSBitmapImageRep *destImageRep = [[lastPicture representations] objectAtIndex:0];
	if (nil == destImageRep)
		return;

	NSEnumerator *enumerator = [inCoordinatesToUpdate objectEnumerator];
	PixelCoordinate* thisCoordinate;

	[pictureLock lock];

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	while ((thisCoordinate = [enumerator nextObject]) != nil) 
	{
		Pixure* thisPixure = [[self population] pixureAtCoordinate:thisCoordinate];
		if (nil == thisPixure)
			continue;
		[destImageRep setColor:[thisPixure color] atX:[thisCoordinate x] y:[thisCoordinate y]];
	}
	
	[pool release];
		
	[[self updateQueue] removeAllObjects];
	
	[pictureLock unlock];
}

#pragma mark -
#pragma mark Accessors


- (PixurePopulation*)population;
{ 
	return [[population retain] autorelease]; 
}


- (void)setPopulation:(PixurePopulation*)inPopulation;
{
	if ([[self population] isEqualTo:inPopulation])
		return;

// retaining here will cause a retain loop
//	[inPopulation retain];
//	[population release];
	population = inPopulation;
}

- (NSMutableArray*)updateQueue;
{
	return updateQueue;
}


- (NSImage*)image;
{
	// safety first
	if (![[self population] numberOfRows])
		return nil;

	// if we already have a picture generated, then update it and return it
	if (nil != lastPicture)
	{	
		[self updateImageAtCoordinates:[self updateQueue]];
		return lastPicture;
	}
	
	lastPicture = [[self generateImage] retain];
	return lastPicture;
}

#pragma mark -
#pragma mark Updating

- (void)clear;
{
	if (nil == lastPicture)
		return; // no need to do anything

	[lastPicture release];
	lastPicture = nil;
}


- (void)addCoordinatesToUpdateQueue:(NSArray*)inCoordinatesToUpdate;
{
	if (nil == updateQueue)
		updateQueue = [[NSMutableArray alloc] init];
	[updateQueue addObjectsFromArray:inCoordinatesToUpdate];
}

@end
