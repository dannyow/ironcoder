//
//  IG2DArray.m
//  LifeLike
//
//  Created by Ian Gowen on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "IG2DArray.h"


@implementation IG2DArray

-(IG2DArray*) init
{
	return nil;
}

- (IG2DArray*) initWithWidth:(int)w height:(int)h
{
	self = [super init];
	if (self) {
		backend = [[NSMutableArray alloc] initWithCapacity:w*h];
		
		width = w;
		height = h;
	}
	
	return self;
}

- (int)width { return width; }
- (int)height { return height; }

// Returns nil if out of bounds
- (id)objectAtRow:(int) row column:(int)column
{
	if (row < 0 || row >= height || column < 0 || column >= width || row*width+column >= [backend count] || 
		[backend objectAtIndex:row*width+column] == [NSNull null]) return nil;
	return [backend objectAtIndex:row*width+column];
}

// Has no effect if out of bounds
- (void)replaceObjectAtRow:(int)row column:(int) column withObject:(id)object
{
	if (row < 0 || row >= height || column < 0 || column >= width) return;
	int index = row*width+column;
	if (index >= [backend count])
	{
		int i;
		for (i = [backend count]; i <= index+1; i++) [backend addObject:[NSNull null]];
	}
	NSAssert(row*width+column <= [backend count]-1, @"Bad length");
	if (object == nil) 	[backend replaceObjectAtIndex:row*width+column withObject:[NSNull null]];
	else				[backend replaceObjectAtIndex:row*width+column withObject:object];
}

- (NSArray *)getNeighborsAtRow:(int)row column:(int)column
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:8]; // A cell has at most 8 neighbors
	id cell;
	if (cell = [self objectAtRow:row-1 column:column])		[array addObject:cell];
	if (cell = [self objectAtRow:row+1 column:column])		[array addObject:cell];	
	if (cell = [self objectAtRow:row-1 column:column-1])	[array addObject:cell];
	if (cell = [self objectAtRow:row-1 column:column+1])	[array addObject:cell];
	if (cell = [self objectAtRow:row+1 column:column-1])	[array addObject:cell];
	if (cell = [self objectAtRow:row+1 column:column+1])	[array addObject:cell];
	if (cell = [self objectAtRow:row column:column-1])		[array addObject:cell];
	if (cell = [self objectAtRow:row column:column+1])		[array addObject:cell];
	return array;
}

// Gets the number of non-nil neighbors of the given element
- (NSNumber *)neighborsAtRow:(int)row column:(int)column
{
	int total = 0;
	if ([self objectAtRow:row-1 column:column])		total++;
	if ([self objectAtRow:row+1 column:column])		total++;
	if ([self objectAtRow:row-1 column:column-1])	total++;
	if ([self objectAtRow:row-1 column:column+1])	total++;
	if ([self objectAtRow:row+1 column:column-1])	total++;
	if ([self objectAtRow:row+1 column:column+1])	total++;
	if ([self objectAtRow:row column:column-1])		total++;
	if ([self objectAtRow:row column:column+1])		total++;
	return [NSNumber numberWithInt:total];
}

- (void)dealloc
{
	[backend release];
	[super dealloc];
}

@end
