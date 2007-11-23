/*
 * Project:     Discoban
 * File:        DiscobanWindow.m
 * Author:      Andrew Wellington
 * Created:     17/11/07
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

#import "DiscobanWindow.h"

#import "ApplicationController.h"
#import "GameBoard.h"

#define kLeftKeyCode	123
#define kRightKeyCode	124
#define kDownKeyCode	125
#define kUpKeyCode		126

#define kReturnKeyCode	36
#define kSpaceKeyCode	49

@implementation DiscobanWindow
- (void)keyDown:(NSEvent *)event
{
	NSLog(@"Received event: %@", event);

	GameBoard *board;
	ApplicationController *controller;
	
	controller = (ApplicationController *)[[NSApplication sharedApplication] delegate];
	board = [controller board];
	if ([board completed]) {
		if ([event keyCode] == kSpaceKeyCode)
			[controller nextLevel];
		return;
	}
	
	if (![controller gameRunning]) {
		if ([event keyCode] == kSpaceKeyCode)
			[controller startGame];
		return;
	}
	
	switch ([event keyCode]) {
		case kLeftKeyCode:
			[board moveLeft];
			break;
		case kRightKeyCode:
			[board moveRight];
			break;
		case kDownKeyCode:
			[board moveDown];
			break;
		case kUpKeyCode:
			[board moveUp];
			break;
		case kReturnKeyCode:
			if ([event modifierFlags] & NSCommandKeyMask)
				[controller nextLevel];
			else if ([event modifierFlags] & NSShiftKeyMask)
				[controller nextTrack];
			else
				[controller reloadLevel];
			break;
		default:
			[super keyDown: event];
			break;
	}
}

@end
