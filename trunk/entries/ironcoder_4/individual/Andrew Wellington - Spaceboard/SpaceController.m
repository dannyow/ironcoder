/*
 * Project:     Spaceboard
 * File:        SpaceController.m
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

#import "SpaceController.h"

#import "MaskWindow.h"
#import "MaskView.h"
#import "SpaceWindow.h"
#import "SpaceView.h"
#import "AWRippler.h"

#import <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>
#include <time.h>
#include <sys/param.h>
#include <sys/mount.h>

#define	SPACE_FONT			@"Lucida Grande"
#define SPACE_FONT_SIZE		36
#define SPACE_FONT_COLOUR	[NSColor whiteColor]

#define SPACE_BOX_RADIUS	25
#define SPACE_BOX_MARGIN	15

#define QUIT_HOTKEY_ID		1
#define SHOWHIDE_HOTKEY_ID	2

/* CoreGraphics private stuff */
extern CGSConnection _CGSDefaultConnection(void);
extern OSStatus CGSGetWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnection cid, const CGSWindow wid, int *tags, int thirtyTwo);

/* Interface for Core Image Core Graphics Server filter */
@interface CICGSFilter : NSObject
{
    void *_cid;
    unsigned int _filter_id;
}

+ (id)filterWithFilter:(CIFilter *)filter connectionID:(CGSConnection)cid;
- (id)initWithFilter:(CIFilter *)filter connectionID:(CGSConnection)cid;
- (void)dealloc;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValuesForKeysWithDictionary:(NSDictionary *)dict;
- (int)addToWindow:(CGSWindow)windowID flags:(unsigned int)flags;
- (int)removeFromWindow:(CGSWindow)windowID;
- (id)description;
@end

@implementation SpaceController

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID command;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
					  sizeof(command),NULL,&command);
	int l = command.id;
	
	switch (l)
	{
		case QUIT_HOTKEY_ID:
			[[NSApplication sharedApplication] terminate: nil];
			break;
		case SHOWHIDE_HOTKEY_ID:
			[[[NSApplication sharedApplication] delegate] toggleSpaceboard];
			break;
	}
			
	return noErr;
}

- (void)awakeFromNib
{
	EventHotKeyRef		myQuitHotKeyRef;
	EventHotKeyID		myQuitHotKeyID;
	EventTypeSpec		myQuitEventSpec;
	EventHotKeyRef		myShowHideHotKeyRef;
	EventHotKeyID		myShowHideHotKeyID;
	
	spaceboardVisible = NO;
	
	myQuitEventSpec.eventClass	= kEventClassKeyboard;
	myQuitEventSpec.eventKind	= kEventHotKeyPressed;
	InstallApplicationEventHandler(&hotKeyHandler, 1, &myQuitEventSpec, NULL, NULL);
	myQuitHotKeyID.signature	= 'ovar';
	myQuitHotKeyID.id			= QUIT_HOTKEY_ID;
	RegisterEventHotKey(0x76, cmdKey + optionKey, myQuitHotKeyID, GetApplicationEventTarget(), 0, &myQuitHotKeyRef);
	
	myShowHideHotKeyID.signature	= 'ovar';
	myShowHideHotKeyID.id			= SHOWHIDE_HOTKEY_ID;
	RegisterEventHotKey(0x7a, cmdKey, myShowHideHotKeyID, GetApplicationEventTarget(), 0, &myShowHideHotKeyRef);
}

static NSString *convertToHumanValue(double bytesOfGoodness)
{
	double abval;
	unsigned int unit_sz;
	NSString *humanValue;
	
	abval = fabs(bytesOfGoodness);
	
	unit_sz = abval ? ilogb(abval) / 10 : 0;
	bytesOfGoodness /= (double)pow(1024, unit_sz);
	
	if (bytesOfGoodness == 0)
		humanValue = [NSString stringWithFormat:@"0B"];
	else if (bytesOfGoodness > 10)
		humanValue = [NSString stringWithFormat:@"%.0f%c", bytesOfGoodness, "BKMGTPE"[unit_sz]];
	else
		humanValue = [NSString stringWithFormat:@"%.1f%c", bytesOfGoodness, "BKMGTPE"[unit_sz]];
	
	return humanValue;
}

- (NSAttributedString *)diskUsageString
{
	NSArray						*volumes;
	NSEnumerator				*volumeEnum;
	NSString					*volume;
	struct statfs				fs;
	NSMutableString				*str;
	NSDictionary				*attrs;
	
	attrs = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSFont fontWithName:SPACE_FONT size:SPACE_FONT_SIZE], NSFontAttributeName,
		SPACE_FONT_COLOUR, NSForegroundColorAttributeName,
		nil];
	str = [[NSMutableString alloc] init];
	
	volumes = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
	volumeEnum = [volumes objectEnumerator];
	while ((volume = [volumeEnum nextObject]))
	{
		if (statfs([volume fileSystemRepresentation], &fs))
			continue;
		
		[str appendFormat:@"%@%@: %@ of %@ (%.0f%%)",
			[str length] ? @"\n" : @"",
			volume,
			convertToHumanValue((double)((fs.f_blocks - fs.f_bfree)) * (double)fs.f_bsize),
			convertToHumanValue((double)fs.f_blocks * (double)fs.f_bsize),
			100.0 - (((float)fs.f_bfree / (float)fs.f_blocks) * 100.0)];
	}
	
	return [[[NSAttributedString alloc] initWithString:str attributes:attrs] autorelease];
}

- (void)toggleSpaceboard
{
	if (spaceboardVisible)
		[self hideSpaceboard: self];
	else
		[self showSpaceboard: self];
}

- (void)hideSpaceboard:(id)sender
{
	[maskMonoWin orderOut:self];
	[spaceWin orderOut:self];
	
	spaceboardVisible = NO;
}

- (void)showSpaceboard:(id)sender
{
	NSRect			rect;
	NSScreen		*screen;
	NSArray			*screens;
	NSEnumerator	*screenEnum;
	
	CIFilter		*maskFilter;
	CICGSFilter		*windowMaskFilter;
	
	NSAttributedString *str;
	
	rect = NSMakeRect(0.0,0.0,0.0,0.0);
	
	screens = [NSScreen screens];
	screenEnum = [screens objectEnumerator];
	while ((screen = [screenEnum nextObject]))
	{
		rect = NSUnionRect(rect,[screen frame]);
	}
		
	maskMonoWin = [[MaskWindow alloc] initWithContentRect:rect
												styleMask:NSBorderlessWindowMask
												  backing:NSBackingStoreNonretained
													defer:NO];
	[maskMonoWin setContentView:[[MaskView alloc] initWithFrame:[maskMonoWin frame]]];
	[maskMonoWin setLevel:NSFloatingWindowLevel];
	[maskMonoWin orderFrontRegardless];
	
	maskFilter = [CIFilter filterWithName:@"CIColorControls"];
	[maskFilter setDefaults];
	[maskFilter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputSaturation"];
	[maskFilter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputBrightness"];
	[maskFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputContrast"];
	
	windowMaskFilter = [CICGSFilter filterWithFilter:maskFilter connectionID:_CGSDefaultConnection()];
	[windowMaskFilter addToWindow:[maskMonoWin windowNum] flags:0x3001];
	
	/* I was going to have a blur on the background as well as the greyscale, but it hurt my eyes so I figured that was a bad thing */
/*
	maskBlurWin = [[MaskWindow alloc] initWithContentRect:CGRectToNSRect(rect)
												styleMask:NSBorderlessWindowMask
												  backing:NSBackingStoreNonretained
													defer:NO];
	[maskBlurWin setContentView:[[MaskView alloc] initWithFrame:[maskBlurWin frame]]];
	[maskBlurWin setLevel:NSFloatingWindowLevel];
	[maskBlurWin orderFrontRegardless];
	
	maskFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[maskFilter setDefaults];
	[maskFilter setValue:[NSNumber numberWithFloat:0.1] forKey:@"inputRadius"];
	[maskFilter retain];
	
	windowMaskFilter = [[CICGSFilter filterWithFilter:maskFilter connectionID:_CGSDefaultConnection()] retain];
	[windowMaskFilter addToWindow:[maskBlurWin windowNum] flags:0x3001];
	*/
	str = [self diskUsageString];
	screen = [[NSScreen screens] objectAtIndex:0];
	rect = NSMakeRect([screen frame].origin.x + (([screen frame].size.width - [str size].width) / 2) - SPACE_BOX_MARGIN,
					  [screen frame].origin.y + (([screen frame].size.height - [str size].height) / 2) - SPACE_BOX_MARGIN,
					  [str size].width + 2 * SPACE_BOX_MARGIN,
					  [str size].height + 2 * SPACE_BOX_MARGIN);
	spaceWin = [[SpaceWindow alloc] initWithContentRect:rect
												styleMask:NSBorderlessWindowMask
												backing:NSBackingStoreBuffered
												  defer:NO];
	[spaceWin setContentView:[[SpaceView alloc] initWithFrame:[spaceWin frame]]];
	[(SpaceView *)[spaceWin contentView] setString:str];
	[spaceWin setLevel:NSFloatingWindowLevel+1];
	[spaceWin orderFrontRegardless];
	[spaceWin ripple];
	
	spaceboardVisible = YES;
}

@end
