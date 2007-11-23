/*
 * Project:     Discoban
 * File:        Tile.m
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

#import "Tile.h"

#import "TileView.h"

#import "WallTile.h"
#import "TargetTile.h"
#import "FloorTile.h"
#import "PlayerCharacter.h"
#import "CrateCharacter.h"

@implementation Tile

@synthesize character;

+ (id)tileWithType:(unichar)tileType
{
	Tile *tile;
	Character *character;
	
	switch (tileType) {
		case ' ':
			tile = [[FloorTile alloc] init];
			break;
		case '#':
			tile = [[WallTile alloc] init];
			break;
		case '$':
			tile = [[FloorTile alloc] init];
			character = [[CrateCharacter alloc] init];
			[tile setCharacter:character];
			break;
		case '.':
			tile = [[TargetTile alloc] init];
			break;
		case '+':
			tile = [[TargetTile alloc] init];
			character = [[PlayerCharacter alloc] init];
			[tile setCharacter:character];
			break;			
		case '*':
			tile = [[TargetTile alloc] init];
			character = [[CrateCharacter alloc] init];
			[tile setCharacter:character];
			break;
		case '@':
			tile = [[FloorTile alloc] init];
			character = [[PlayerCharacter alloc] init];
			[tile setCharacter:character];
			break;			
	}
	return tile;
}

- (TileView *)view
{
	if (!view) {
		Class viewClass = NSClassFromString([NSString stringWithFormat:@"%@View", NSStringFromClass([self class])]);
		view = [[viewClass alloc] init];
	}
	
	return view;	
}

- (BOOL)impassable
{
	return YES;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p; Character=%@>", 
			NSStringFromClass([self class]),
			self,
			character ? character : @"(null)"];
}

- (NSString *)descriptionCharacter
{
	return @"!";
}

@end
