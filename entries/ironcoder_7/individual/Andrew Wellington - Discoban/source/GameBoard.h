/*
 * Project:     Discoban
 * File:        GameBoard.h
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

#import <Cocoa/Cocoa.h>

#define BOARD_MAX_W		32
#define BOARD_MAX_H		32

@class Tile;

@interface GameBoard : NSObject {
	Tile *board[BOARD_MAX_H][BOARD_MAX_W];
	NSUInteger actualWidth;
	NSUInteger actualHeight;
	NSUInteger playerX;
	NSUInteger playerY;
	BOOL completed;
}

- (id)initWithFile:(NSString *)filename;
- (void)setTile:(Tile *)tile atX:(NSUInteger)xPos Y:(NSUInteger)yPos;
- (Tile *)tileAtX:(NSUInteger)xPos Y:(NSUInteger)yPos;
- (NSUInteger)actualHeight;
- (NSUInteger)actualWidth;
- (BOOL)completed;

- (void)moveRight;
- (void)moveLeft;
- (void)moveDown;
- (void)moveUp;


@end
