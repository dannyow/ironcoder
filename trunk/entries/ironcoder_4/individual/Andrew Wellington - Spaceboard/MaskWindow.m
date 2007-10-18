/*
 * Project:     Spaceboard
 * File:        MaskWindow.m
 * Author:      Andrew Wellington
 *
 * License:
 * Copyright (C) 2006 Andrew Wellington.
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

#import "MaskWindow.h"

typedef int CGSConnection;
typedef int CGSWindow;
extern CGSConnection _CGSDefaultConnection(void);
extern OSStatus CGSGetWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);

@implementation NSWindow(WindowNumAdditions)
- (int)windowNum
{
    return _windowNum;
}
@end

@implementation MaskWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	
    NSWindow* result = [super initWithContentRect:contentRect
										styleMask:NSBorderlessWindowMask
										  backing:NSBackingStoreBuffered
											defer:NO];
    [result setBackgroundColor: [NSColor clearColor]];
    [result setAlphaValue:1.0];
    [result setOpaque:NO];
	int tags[2] = { 0, 0 };
	
	if (!CGSGetWindowTags(_CGSDefaultConnection(), _windowNum, tags, 32)) {
		tags[0] = tags[0] | 0x00000800;
		CGSSetWindowTags(_CGSDefaultConnection(), _windowNum, tags, 32);
	}	
	
    return result;
}

@end
