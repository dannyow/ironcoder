/*
 * Project:     Discoban
 * File:        GameBoard.m
 * Author:      Andrew Wellington
 * Created:     16/11/07
 *
 * License:
 * Copyright (C) 2007 Andrew Wellington.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "GameBoard.h"

#import <QuartzCore/QuartzCore.h>

#import "ApplicationController.h"

#import "Tile.h"
#import "TileView.h"

#import "TargetTile.h"
#import "PlayerCharacter.h"
#import "CrateCharacter.h"

#include <strings.h>

@interface GameBoard()
- (void)movedx:(NSInteger)dx dy:(NSInteger)dy;
- (BOOL)checkForWin;
@end

@implementation GameBoard
- (id)initWithFile:(NSString *)filename
{
	[super init];
	
	bzero(board, sizeof(Tile *) * BOARD_MAX_H * BOARD_MAX_W);
	actualWidth = 0;
	actualHeight = 0;
	completed = NO;
	
	NSUInteger playerCharacterCount = 0;
	NSUInteger targetTileCount = 0;
	NSUInteger crateCharacterCount = 0;
	
	NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filename];
	fileContent = [fileContent stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
 	NSArray *fileLines = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSUInteger row = 0;
	for (NSString *line in fileLines) {
		NSUInteger i;
		
		for (i = 0; i < [line length]; i++) {
			unichar tileRep = [line characterAtIndex:i];
			Tile *tile = [Tile tileWithType:tileRep];
			[self setTile:tile atX:i Y:row];
			
			if ([tile isKindOfClass:[TargetTile class]])
				targetTileCount++;
			if ([[tile character] isKindOfClass:[PlayerCharacter class]]) {
				playerCharacterCount++;
				playerX = i;
				playerY = row;
			}
			else if ([[tile character] isKindOfClass:[CrateCharacter class]])
				crateCharacterCount++;
		}
		
		row++;
	}
	
	NSLog(@"Created Level: %@", self);
	
	if (crateCharacterCount > targetTileCount) {
		NSLog(@"crateCharacterCount > targetTileCount: %u > %u", 
			  crateCharacterCount,
			  targetTileCount);
		return nil;
	}
	
	if (playerCharacterCount != 1) {
		NSLog(@"playerCharacterCount != 1: %d", 
			playerCharacterCount);
		return nil;
	}
	
	//NSLog(@"Totals:\n  playerCharacterCount = %u;\n  crateCharacterCount = %u\n  targetTileCount = %u",
	//	  playerCharacterCount,
	//	  crateCharacterCount,
	//	  targetTileCount);
	
	return self;
}

- (void)setTile:(Tile *)tile atX:(NSUInteger)xPos Y:(NSUInteger)yPos
{
	board[yPos][xPos] = tile;
}

- (Tile *)tileAtX:(NSUInteger)xPos Y:(NSUInteger)yPos
{
	return board[yPos][xPos];
}

- (NSUInteger)actualHeight
{
	NSUInteger height;
	
	if (actualHeight)
		return actualHeight;
	
	for (height = 0; height < BOARD_MAX_H; height++) {
		NSUInteger i;
		for (i = 0; i < BOARD_MAX_W; i++)
			if ((board[height][i]) && (![board[height][i] isKindOfClass:[FloorTile class]]))
				break;
		if (i == BOARD_MAX_W)
			break;
	}
	
	actualHeight = height;
	return height;
}

- (NSUInteger)actualWidth
{
	NSUInteger width = 0;
	NSUInteger height;
	NSUInteger maxHeight = [self actualHeight];
	
	if (actualWidth)
		return actualWidth;
	
	for (height = 0; height < BOARD_MAX_H; height++) {
		NSUInteger i;
		for (i = 0; i < BOARD_MAX_W; i++)
			if ((board[height][i]) && (![board[height][i] isKindOfClass:[FloorTile class]]))
				width = MAX(width, i+1);
		if (height == maxHeight)
			break;
	}
	
	actualWidth = width;
	return width;
}

- (void)movedx:(NSInteger)dx dy:(NSInteger)dy
{
	Tile *currentTile;
	Tile *newTile;
	Tile *newCrateTile = nil;
	Character *playerCharacter;
	Character *crateCharacter = nil;
	
	if (completed)
		return;
	
	currentTile = [self tileAtX:playerX Y:playerY];
	newTile = [self tileAtX:playerX + dx Y:playerY + dy];
	playerCharacter = [currentTile character];
	
//	if (!newTile) {
//		newTile = [Tile tileWithType:' '];
//		[self setTile:newTile atX:playerX + dx Y:playerY + dy];
//	}
	
	if ([newTile impassable]) {
		//NSBeep();
		return;
	}
	
	if ([[newTile character] isKindOfClass:[CrateCharacter class]])
	{
		newCrateTile = [self tileAtX:playerX + 2*dx Y:playerY + 2*dy];
		if ([newCrateTile impassable] || [newCrateTile character]) {
			//NSBeep();
			return;
		}
		crateCharacter = [newTile character];
	}
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.1] forKey:kCATransactionAnimationDuration];
	[[[playerCharacter view] animator] setFrame:[[newTile view] frame]];

	if (crateCharacter) {
		[[[crateCharacter view] animator] setFrame:[[newCrateTile view] frame]];
	}

	playerX += dx;
	playerY += dy;

	if (newCrateTile)
		[newCrateTile setCharacter:crateCharacter];
	[newTile setCharacter:playerCharacter];
	[currentTile setCharacter:nil];
	
	if ([self checkForWin]) {
		completed = YES;
		[(ApplicationController *)[NSApp delegate] completedLevel];
	}
	
	[CATransaction commit];
}

- (void)moveRight
{
	[self movedx:1 dy:0];
}

- (void)moveLeft
{
	[self movedx:-1 dy:0];
}

- (void)moveDown
{
	[self movedx:0 dy:1];
}

- (void)moveUp
{
	[self movedx:0 dy:-1];
}

- (BOOL)completed
{
	return completed;
}

- (BOOL)checkForWin
{
	NSUInteger width, height;
	NSUInteger x, y;
	
	height = [self actualHeight];
	width = [self actualWidth];
	
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			Tile *tile = [self tileAtX:x Y:y];
			if ([[tile character] isKindOfClass:[CrateCharacter class]] &&
				![tile isKindOfClass:[TargetTile class]])
				return NO;
		}
	}
	return YES;
}

- (NSString *)description
{
	NSUInteger width, height;
	NSUInteger x, y;
	
	height = [self actualHeight];
	width = [self actualWidth];
		
	NSMutableString *desc = [[NSMutableString alloc] init];
	[desc appendString:@"Level: {\n"];
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			Tile *tile = [self tileAtX:x Y:y];
			if (tile)
				[desc appendString:[tile descriptionCharacter]];
			else
				[desc appendString:@" "];
		}
		[desc appendString:@"\n"];
	}
	[desc appendString:@"}"];
	return desc;
}

@end
