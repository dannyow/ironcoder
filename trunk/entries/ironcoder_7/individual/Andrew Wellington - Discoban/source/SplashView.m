/*
 * Project:     Discoban
 * File:        SplashView.m
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


#import "SplashView.h"


@implementation SplashView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setWantsLayer:YES];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	NSRect frame = [self frame];
	NSColor *color = [NSColor colorWithCalibratedRed:0
											   green:0
												blue:0
											   alpha:0.75];
	[color set];
    NSRectFill(frame);
	
	NSString *levelCompleteText = NSLocalizedString(@"Welcome to Discoban", @"");
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSFont systemFontOfSize:24],
						   NSFontAttributeName,
						   [NSColor whiteColor],
						   NSForegroundColorAttributeName,
						   nil];
	NSSize strSize = [levelCompleteText sizeWithAttributes:attrs];
	NSPoint textPoint;
	textPoint.x = (frame.size.width - strSize.width) / 2;
	textPoint.y = (frame.size.height - strSize.height) / 2;
	
	[levelCompleteText drawAtPoint:textPoint
					withAttributes:attrs];
	
	NSString *spaceToContinueText = NSLocalizedString(@"Use arrow keys to move.\nReturn to reload levels.\nPress Space to start.", @"");
	attrs = [NSDictionary dictionaryWithObjectsAndKeys:
			 [NSFont systemFontOfSize:[NSFont smallSystemFontSize]],
			 NSFontAttributeName,
			 [NSColor whiteColor],
			 NSForegroundColorAttributeName,
			 nil];
	
	strSize = [spaceToContinueText sizeWithAttributes:attrs];
	textPoint.y -= strSize.height;
	textPoint.x = (frame.size.width - strSize.width) / 2;
	
	[spaceToContinueText drawAtPoint:textPoint
					  withAttributes:attrs];
}

@end
