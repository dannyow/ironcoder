/*
 * Project:     Discoban
 * File:        MusicPlayer.m
 * Author:      Andrew Wellington
 * Created:     18/11/07
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


#import "MusicPlayer.h"
#include <stdlib.h>

@implementation MusicPlayer
- (id)init
{
	[super init];
	
	musicList = [[NSBundle mainBundle] pathsForResourcesOfType:@"m4a" inDirectory:@"Music"];
	
	return self;
}

- (void)startPlaying
{
	index = random() % [musicList count];
	[self playNextTrack];
}

- (void)stopPlaying
{
	[player pause];
}

- (void)playNextTrack
{
	if ([musicList count] == 0)
		return;

	if ([player isPlaying])
		[player pause];
	
	if ([musicList count] <= index)
		index = 0;
	
	player  = [[NSSound alloc] initWithContentsOfFile:[musicList objectAtIndex:index]
										  byReference:YES];
	[player setDelegate:self];
	if (![player play])
		NSLog(@"Couldn't start music!");
	
	index++;
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
	[self playNextTrack];
}

@end
