//
//  PopulationmGeneratedImage.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/31/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PixurePopulation;

@interface PopulationGeneratedImage : NSObject {
	PixurePopulation*	population;
	
	NSMutableArray* updateQueue;
	
	NSImage* lastPicture;
	
	NSLock* pictureLock;
}

- (id)initWithPopulation:(PixurePopulation*)inPopulation;

- (void)setPopulation:(PixurePopulation*)inPopulation;

- (NSImage*)image;

//- (void)updateImageAtCoordinates:(NSArray*)inCoordinatesToIpdate;

- (void)addCoordinatesToUpdateQueue:(NSArray*)inCoordinatesToUpdate;

- (void)clear;

@end
