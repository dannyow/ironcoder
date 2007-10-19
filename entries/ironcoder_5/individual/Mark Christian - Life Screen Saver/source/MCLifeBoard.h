//
//  MCLifeBoard.h
//  Life
//
//  Created by Mark Christian on 30/03/07.
//  Copyright 2007 ShinyPlasticBag. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MCLifeBoard : NSObject
{
	NSMutableArray *board;
	int boardWidth, boardHeight;
	int cellSize;
	NSMutableArray *diff;
	int maxX, maxY;
	int minX, minY;
}

#pragma mark -
#pragma mark Cell-related functions

- (NSPoint)cellAbove:(NSPoint)p;
- (NSPoint)cellBelow:(NSPoint)p;
- (NSPoint)cellLeft:(NSPoint)p;
- (NSPoint)cellRight:(NSPoint)p;
- (BOOL)cellShouldLive:(NSPoint)p;
- (int)livingNeighbourCountForCell:(NSPoint)point;
- (NSArray *)neighboursForCell:(NSPoint)point;
- (void)setStateForCellAtX:(int)x Y:(int)y alive:(BOOL)alive;
- (void)setStateForCell:(NSPoint)point alive:(BOOL)alive;
- (BOOL)stateForCellAtX:(int)x Y:(int)y;
- (BOOL)stateForCell:(NSPoint)point;

#pragma mark -
#pragma mark Methods
- (void)clear;
- (void)step;

#pragma mark -
#pragma mark Object methods
- (id)init;
- (id)initWithWidth:(int)width andHeight:(int)height andCellSize:(int)size;

#pragma mark -
#pragma mark Properties
- (int)boardHeight;
- (int)boardWidth;
- (int)cellSize;
- (NSArray *)diff;
@end
