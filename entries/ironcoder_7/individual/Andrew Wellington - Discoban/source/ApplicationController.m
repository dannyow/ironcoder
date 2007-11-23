/*
 * Project:     Discoban
 * File:        ApplicationController.m
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


#import "ApplicationController.h"

#import <QuartzCore/QuartzCore.h>
#include <stdlib.h>

#import "GameBoard.h"
#import "GameBoardView.h"
#import "LevelDoneView.h"
#import "MusicPlayer.h"
#import "SplashView.h"

@interface ApplicationController()
- (void)loadLevel:(NSUInteger)aLevel;
@end

@implementation ApplicationController
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	/*
	int i;
	NSUInteger maxH, maxW;
	maxH = 0;
	maxW = 0;
	for (i = 0; i <= 90; i++) {
		NSString *levelName = [NSString stringWithFormat:@"Level %d", i];
		NSString *levelPath = [[NSBundle mainBundle] pathForResource:levelName
															  ofType:@"txt"
														 inDirectory:@"Levels"];
		GameBoard *theBoard = [[GameBoard alloc] initWithFile:levelPath];
		
		maxH = MAX(maxH, [theBoard actualHeight]);
		maxW = MAX(maxW, [theBoard actualWidth]);
	}
	
	NSLog(@"Largest width: %d; Largest height: %d", maxW, maxH);
	*/
	
    srandomdev();
    
	[self loadLevel:0];
	
	splashView = [[SplashView alloc] initWithFrame:[gameBoardView frame]];
	
	CALayer *layer = [splashView layer];
	layer.zPosition = 2;
	[gameBoardView addSubview:splashView];
}

- (BOOL)gameRunning
{
	return gameRunning;
}

- (void)startGame
{
	music = [[MusicPlayer alloc] init];
	[music startPlaying];
	gameRunning = YES;
	
	[[splashView animator] setAlphaValue:0.0];

}

- (GameBoard *)board
{
	return board;
}

- (void)nextLevel
{
	[self loadLevel:level + 1];
}

- (void)completedLevel
{
	doneView = [[LevelDoneView alloc] initWithFrame:[gameBoardView frame]];
	[doneView setAlphaValue:0.0];
	
	CALayer *layer = [doneView layer];
	layer.zPosition = 2;
	[gameBoardView addSubview:doneView];
	[self performSelector:@selector(fadeInCompletedView:)
			   withObject:nil
			   afterDelay:0.0];
}

 - (void)fadeInCompletedView:(id)sender
{
	[[doneView animator] setAlphaValue:1.0];	
}

- (void)nextTrack
{
	[music playNextTrack];
}

- (IBAction)toggleMusic:(id)sender
{
	if ([sender state] == NSOnState) {
		[music stopPlaying];
		[sender setState:NSOffState];
	} else {
		[music startPlaying];
		[sender setState:NSOnState];
	}
}

- (void)reloadLevel
{
	[self loadLevel:level];
}

- (void)loadLevel:(NSUInteger)aLevel
{	
	NSString *levelName = [NSString stringWithFormat:@"Level %d", aLevel];
	NSString *levelPath = [[NSBundle mainBundle] pathForResource:levelName
														  ofType:@"txt"
													 inDirectory:@"Levels"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:levelPath]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Couldn't find level!", @"")
										 defaultButton:NSLocalizedString(@"OK", @"")
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"The file %@ could not be found on disk", @""),
						  levelName];
		[alert runModal];
		[self loadLevel:level];
		return;
	}
	
	board = [[GameBoard alloc] initWithFile:levelPath];
	[gameBoardView setBoard:board];
	
	level = aLevel;
	
	//NSLog(@"Height: %d, Width: %d", [board actualHeight], [board actualWidth]);	
}

@end
