//
//  MCLifeBoard.m
//  Life
//
//  Created by Mark Christian on 30/03/07.
//  Copyright 2007 ShinyPlasticBag. All rights reserved.
//

#import "MCLifeBoard.h"

@implementation MCLifeBoard

#pragma mark -
#pragma mark Cell-related functions

- (NSPoint)cellAbove:(NSPoint)p
{
//	return NSMakePoint(p.x, ((int)p.y - 1 + boardHeight) % boardHeight);
	if (p.y == 0) {
		return NSMakePoint(p.x, (float)boardHeight - 1);
	} else {
		return NSMakePoint(p.x, p.y - 1);
	}
}

- (NSPoint)cellBelow:(NSPoint)p
{
//	return NSMakePoint(p.x, ((int)p.y + 1) % boardHeight);
	if (p.y == (float)boardHeight - 1) {
		return NSMakePoint(p.x, 0);
	} else {
		return NSMakePoint(p.x, p.y + 1);
	}
}

- (NSPoint)cellLeft:(NSPoint)p
{
//	return NSMakePoint(((int)p.x - 1 + boardWidth) % boardWidth, p.y);
	if (p.x == 0) {
		return NSMakePoint((float)boardWidth - 1, p.y);
	} else {
		return NSMakePoint(p.x - 1, p.y);
	}
}

- (NSPoint)cellRight:(NSPoint)p
{
//	return NSMakePoint(((int)p.x + 1) % boardWidth, p.y);
	if (p.x == (float)boardWidth - 1) {
		return NSMakePoint(0, p.y);
	} else {
		return NSMakePoint(p.x + 1, p.y);
	}
}

- (BOOL)cellShouldLive:(NSPoint)p
{
	int livingNeighbours = [self livingNeighbourCountForCell:p];
	
	if ([self stateForCell:p])
		return (livingNeighbours == 2 || livingNeighbours == 3);
	else
		return (livingNeighbours == 3);
}

- (int)livingNeighbourCountForCell:(NSPoint)point
{
	//	Variables
	CFIndex i = 0;
	int neighbourCount = 0;
	NSArray *neighbours = [self neighboursForCell:point];
	
	//	Iterate through neighbours
	for(i = 0; i < [neighbours count]; i++) {
		//	Get neighbour cell
		NSValue *value = (NSValue *)[neighbours objectAtIndex:i];
		NSPoint neighbour = [value pointValue];
		
		//	Check state of neighbour cell
		if ([self stateForCell:neighbour])
			neighbourCount++;
	}
	
	//	Finished
	return neighbourCount;
}

- (NSArray *)neighboursForCell:(NSPoint)point
{
	//	Variables
	int i = 0;
	NSMutableArray *neighbours = [NSMutableArray arrayWithCapacity:8];
	NSPoint origin;
	
	//	Get neighbours
	origin = [self cellAbove:point];
	for(i = 0; i < 3; i++) {
		//	Get left and right cells
		[neighbours addObject:[NSValue valueWithPoint:[self cellLeft:origin]]];
		[neighbours addObject:[NSValue valueWithPoint:[self cellRight:origin]]];
		
		//	Get center cell
		if (origin.y != point.y) {
			[neighbours addObject:[NSValue valueWithPoint:origin]];
		}

		//	Move down
		origin = [self cellBelow:origin];
	}
	
	//	Finished
	return neighbours;
}

- (void)setStateForCellAtX:(int)x Y:(int)y alive:(BOOL)alive
{
	NSPoint p = NSMakePoint((float)x, (float)y);
	[self setStateForCell:p alive:alive];
}

- (void)setStateForCell:(NSPoint)point alive:(BOOL)alive
{	
	NSValue *value = [NSValue valueWithPoint:point];
	if ([self stateForCell:point] != alive)
		[diff addObject:value];
	
	//	Remove existing point from board
	if ([board containsObject:value] && !alive)
		[board removeObject:value];
	else if (alive)
		[board addObject:value];
		
}

- (BOOL)stateForCellAtX:(int)x Y:(int)y
{
	NSPoint p = NSMakePoint((float)x, (float)y);
	return [self stateForCell:p];
}

- (BOOL)stateForCell:(NSPoint)point
{
	NSValue *value = [NSValue valueWithPoint:point];
	return ([board containsObject:value]);
}

#pragma mark -
#pragma mark Methods
- (void)clear
{
	//	Copy all living cells to diff array
	[diff removeAllObjects];
	CFIndex i;
	for(i = 0; i < [board count]; i++) {
		[diff addObject:[board objectAtIndex:i]];
	}
	
	//	Empty board
	[board removeAllObjects];
}

- (void)step
{
	//	Variables
	NSMutableArray *cellsToCheck = [NSMutableArray array];
	NSMutableArray *newBoard = [[NSMutableArray alloc] init];
	CFIndex i, j;
	
	//	Reset diff array
	[diff removeAllObjects];
	
	//	Iterate through living cells
	for(i = 0; i < [board count]; i++) {
		//	Get cell and add it to list of cells to check
		NSValue *value = (NSValue *)[board objectAtIndex:i];
		NSPoint cell = [value pointValue];
		[cellsToCheck addObject:value];
		
		//	Get neighbours
		NSArray *neighbours = [self neighboursForCell:cell];
		
		//	Iterate through neighbours
		for(j = 0; j < [neighbours count]; j++) {
			//	Get neighbour
			NSValue *neighbourValue = (NSValue *)[neighbours objectAtIndex:j];
			NSPoint neighbourCell = [neighbourValue pointValue];
			
			//	Get value for neighbour
			if (![self stateForCell:neighbourCell] && ![cellsToCheck containsObject:[neighbours objectAtIndex:j]]) {
				//	Neighbour is dead; add it to list of cells to check
				[cellsToCheck addObject:[neighbours objectAtIndex:j]];
			}
		}
	}
	
	//	Iterate through all cells to check and set their new values
	for(i = 0; i < [cellsToCheck count]; i++) {
		//	Get cell
		NSValue *value = (NSValue *)[cellsToCheck objectAtIndex:i];
		NSPoint cell = [value pointValue];
		
		//	See if cell should live
		if ([self cellShouldLive:cell]) {
			//	Add cell to new board
			[newBoard addObject:value];
		}
		
		//	See if cell has changed
		if ([self cellShouldLive:cell] != [self stateForCell:cell]) {
			//	Add to list of changed cells
			[diff addObject:value];
		}
	}

	//	Replace old board with new board
	[board release];
	board = newBoard;
}

#pragma mark -
#pragma mark Object methods
- (id) init
{
	return [self initWithWidth:16 andHeight:16 andCellSize:8];
}

- (id)initWithWidth:(int)width andHeight:(int)height andCellSize:(int)size
{
	self = [super init];
	if (self != nil) {
		//	Set instance variables
		board = [[NSMutableArray alloc] init];
		boardHeight = height;
		boardWidth = width;
		cellSize = size;
		diff = [[NSMutableArray alloc] init];
		minX = 0;
		minY = 0;
		maxX = boardWidth - 1;
		maxY = boardHeight - 1;
		
		//	Populate board with a glider
		/*
		[self setStateForCellAtX:10 Y:10 alive:YES];
		[self setStateForCellAtX:11 Y:11 alive:YES];
		[self setStateForCellAtX: 9 Y:12 alive:YES];
		[self setStateForCellAtX:10 Y:12 alive:YES];
		[self setStateForCellAtX:11 Y:12 alive:YES];
		 */
	}
	return self;
}

#pragma mark -
#pragma mark Properties
- (int)boardHeight
{
	return boardHeight;
}

- (int)boardWidth
{
	return boardWidth;
}

- (int)cellSize
{
	return cellSize;
}

- (NSArray *)diff
{
	return diff;
}

@end
