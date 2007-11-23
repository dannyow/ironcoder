//
//  EtcherController.m
//  Etcher
//
//  Created by Geoff Pado on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "EtcherController.h"
#import "WindowView.h"

#define UNKNOWN 0
#define POWERBOOK 1
#define HIRESPOWERBOOK 3
#define MACBOOK 4

@implementation EtcherController

- (void)awakeFromNib
{
	etcherWindow = [[EtcherWindow alloc] initWithContentRect:NSMakeRect(0, 0, 740, 630) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	etcherView = [[EtcherView alloc] initWithFrame:NSMakeRect(50, 100, 640, 480)];
	WindowView *windowView = [[WindowView alloc] initWithFrame:NSMakeRect(0, 0, 740, 630)];

	NSBox *etcherBezel = [[NSBox alloc] initWithFrame:NSMakeRect(50, 100, 640, 480)];
	[etcherBezel setBoxType:NSBoxCustom];
	[etcherBezel setBorderType:NSGrooveBorder];
	[etcherBezel setBorderWidth:5.0];
	
	leftKnob = [[NSImageView alloc] initWithFrame:NSMakeRect(20, 8, 84, 84)];
	[leftKnob setImage:[NSImage imageNamed:@"etcherwheel"]];
	rightKnob = [[NSImageView alloc] initWithFrame:NSMakeRect(636, 8, 84, 84)];
	[rightKnob setImage:[NSImage imageNamed:@"etcherwheel"]];
	
	[etcherView setWantsLayer:YES];
	[etcherView setDelegate:self];
	
	[windowView addSubview:etcherView];
	[windowView addSubview:leftKnob];
	[windowView addSubview:rightKnob];
	
	[etcherWindow setContentView:windowView];
	[etcherWindow center];
	[etcherWindow setHasShadow:YES];
	[etcherWindow makeFirstResponder:etcherView];
	
	[etcherWindow makeKeyAndOrderFront:self];
	
	//motion tracking stuff
	char *macTypeCName;
	NSString *macTypeName;
	Gestalt('mnam', &macTypeCName);
	macTypeName = [[[NSString alloc] initWithCString:macTypeCName] autorelease];

	structSize = 57;

	if([macTypeName rangeOfString:@"MacBook"].length != 0) 
	{
		macType = MACBOOK;
		structSize = 37;
	}
	
	else if([macTypeName rangeOfString:@"PowerBook5,6"].length != 0) 
	{
		macType = POWERBOOK;
	}
	
	else if([macTypeName rangeOfString:@"PowerBook5,7"].length != 0) 
	{
		macType = POWERBOOK;
	} 
	
	else if([macTypeName rangeOfString:@"PowerBook6,8"].length != 0)
	{
		macType = HIRESPOWERBOOK;
	}
	
	else if([macTypeName rangeOfString:@"PowerBook5,"].length != 0) 
	{
		macType = HIRESPOWERBOOK;
	}
	
	else if([macTypeName rangeOfString:@"PowerBook"].length != 0) 
	{
		macType = POWERBOOK;
	}
	
	else {
		macType = MACBOOK;
		structSize = 37;
	}
	
	NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getPosition:) userInfo:nil repeats:YES] retain];
	[timer release];
}

- (IBAction)showHelp:(id)sender
{
	NSRect etcherFrame = [etcherWindow frame];
	[helpWindow setFrame:[helpWindow frameRectForContentRect:NSMakeRect((etcherFrame.origin.x + (etcherFrame.size.width / 2) - 186), (etcherFrame.origin.y - 70), 372, 141)] display:YES];
	helpWindow.alphaValue = 0;
	[helpWindow makeKeyAndOrderFront:self];
	[helpWindow setDelegate:self];
	[[helpWindow animator] setAlphaValue:1.0];
}

- (BOOL)windowShouldClose:(id)window
{
	[[helpWindow animator] setAlphaValue:0.0];
	return NO;
}

- (void)spinDial:(NSString *)dial distance:(int)distance
{
	NSImageView *spinDial;
	
	if ([dial isEqualToString:@"x"])
	{
		spinDial = leftKnob;
	}
	
	else if ([dial isEqualToString:@"y"])
	{
		spinDial = rightKnob;
	}
	
	//[spinDial setWantsLayer:YES];
	[spinDial layer].anchorPoint = CGPointMake(0.5, 0.5);
	
	CGFloat currentRotation = [spinDial frameRotation];
	CGFloat newRotation = (currentRotation + (distance * 3));
	[[spinDial animator] setFrameCenterRotation:newRotation];
}

- (IBAction)clearEtcher:(id)sender
{
	if (!isShaking) 
	{
		isShaking = YES;
		isShaking = [self shakeWindow];
	}
}

- (void)getPosition:(NSTimer *)sender
{
	int gyro[3];
	if (getMotion(macType, structSize, gyro) == 1)
	{
		if ((gyro[0] > 50 | gyro[1] > 50 | gyro[2] > 50) & !isShaking)
		{
			isShaking = YES;
			isShaking = [self shakeWindow];
		}
	}
}

- (BOOL)shakeWindow
{
	int i = 0;
	srand(time(NULL));

	for (i = 0; i < 20; i++)
	{
		[etcherView dropOpacity];
		NSRect currentFrame = [etcherWindow frame];
		int yDelta = (rand() % 50) - 25;
		NSRect newFrame = NSMakeRect(currentFrame.origin.x, currentFrame.origin.y + yDelta, currentFrame.size.width, currentFrame.size.height);
		[etcherWindow setFrame:newFrame display:YES animate:YES];
		[[etcherWindow animator] center]; 
	}
	[etcherView clearPath];
	return NO;
}
@end
