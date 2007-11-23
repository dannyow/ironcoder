/*
 * Project:     Discoban
 * File:        GameBoardView.m
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

#import "GameBoardView.h"

#import <QuartzCore/QuartzCore.h>

#import "GameBoard.h"
#import "Tile.h"
#import "Character.h"

#import "TileView.h"
#import "CharacterView.h"

@interface GameBoardView()
- (NSString *)imageName;
- (void)createViewsForTilesAndCharacters;
@end

@implementation GameBoardView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		background = [NSImage imageNamed:[self imageName]];
		if (!background)
		{			
			background = [[NSImage alloc] initByReferencingFile:
					 [[NSBundle mainBundle] pathForResource:[self imageName]
													 ofType:@"png"
												inDirectory:@"Graphics"]];
			[background setName:[self imageName]];
		}
    }
    return self;
}

- (NSString *)imageName
{
	return @"Background";
}

- (void)drawRect:(NSRect)rect {
	[background drawInRect:rect
				  fromRect:NSZeroRect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
	
	[boardImage drawInRect:rect
				  fromRect:NSZeroRect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
}

- (GameBoard *)board
{
	return board;
}

- (void)setBoard:(GameBoard *)aBoard
{
	board = aBoard;
	boardImage = [[NSImage alloc] initWithSize:[self frame].size];
	[self createViewsForTilesAndCharacters];
}

- (void)createViewsForTilesAndCharacters
{
	NSUInteger x, y;
	NSUInteger height, width;
	
	NSUInteger offsetX, offsetY;
	
	for (NSView *view in [[self subviews] copy]) {
		[view removeFromSuperview];
	}
	
	height = [board actualHeight];
	width = [board actualWidth];
	
	/* Center level */
	offsetX = ([self frame].size.width - (TILE_WIDTH * width)) / 2;
	offsetY = ([self frame].size.height - (TILE_HEIGHT * height)) / 2;

	[boardImage lockFocus];
	
	/* Generate a view for each character, and an image for the level */
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			Tile *tile = [board tileAtX:x Y:y];
			if (!tile)
				continue;
			TileView *tileView = [tile view];
			NSRect tileRect = NSMakeRect(x * TILE_WIDTH + offsetX, 
										(height - y - 1) * TILE_HEIGHT + offsetY,
			TILE_WIDTH, TILE_HEIGHT);
			[tileView setFrame:tileRect];
			
			[[tileView image] drawInRect:[tileView frame]
								 fromRect:NSZeroRect
								operation:NSCompositeSourceOver
								 fraction:1.0];
						  
			if ([tile character]) {
				CharacterView *characterView = [[tile character] view];
				[characterView setFrameOrigin:NSMakePoint(x * TILE_WIDTH + offsetX, 
													 (height - y - 1) * TILE_HEIGHT + offsetY)];
				[self addSubview:characterView];
				CALayer *layer = [characterView layer];
				layer.zPosition = 1;
			}
		}
	}
	
	[boardImage unlockFocus];
	[self setNeedsDisplay:YES];
}

@end
