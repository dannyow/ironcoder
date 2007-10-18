//
//  AppController.m
//  MyFaces
//
//  Created by Erik Wrenholt on 9/30/06.
//  Copyright 2006 Timestretch Software. All rights reserved.
//

#import "AppController.h"
#import "FullScreenWindow.h"

@implementation AppController

-(void)awakeFromNib
{
	[NSApp setDelegate:self];
	[NSApp runModalForWindow:warning];
}
//--------------------------------------------------------------------
-(IBAction)quit:(id)sender
{
	[NSApp terminate:nil];
}
//--------------------------------------------------------------------
-(IBAction)continue:(id)sender
{

	[warning orderOut:nil];
	[NSApp stopModal];
}
//--------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	
    int windowLevel;
    NSRect screenRect;
	
	CGDisplayFadeReservationToken myToken;
	CGAcquireDisplayFadeReservation(2, &myToken);
	CGDisplayFade (
		myToken,
		1.0,                        // 2 seconds
		kCGDisplayBlendNormal,      // starting state
		kCGDisplayBlendSolidColor,  // ending state
		0.0, 0.0, 0.0,              // black
		TRUE                        // wait for completion
	);

	windowLevel = NSNormalWindowLevel;
	
    // Get the screen rect of our main display
    screenRect = [[NSScreen mainScreen] frame];

    // Put up a new window
    mainWindow = [[FullScreenWindow alloc] initWithContentRect:screenRect
                                styleMask:NSBorderlessWindowMask
                                backing:NSBackingStoreBuffered
                                defer:NO screen:[NSScreen mainScreen]];

    [mainWindow setLevel:windowLevel];
    [mainWindow setBackgroundColor:[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0]];


	[mainWindow setAutorecalculatesKeyViewLoop:YES];
	[mainWindow setContentView:myView];
    [mainWindow makeKeyAndOrderFront:nil];

	[mainWindow setInitialFirstResponder:myView];
	[mainWindow makeFirstResponder:myView];
	[myView resetImage];
}

-(IBAction)randomPicture:(id)sender
{
	[myView randomImage];
}

@end
