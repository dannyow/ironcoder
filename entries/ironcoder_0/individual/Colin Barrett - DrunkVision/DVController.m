//
//  DVController.m
//  DrunkVision
//
//  Created by Colin Barrett on 3/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DVController.h"
#import "DVInfo.h"
#import <Carbon/Carbon.h>

#define DV_WINDOW_X_OFFSET 15
#define DV_WINDOW_Y_OFFSET 25
#define DV_WINDOW_TRANSPARENCY 0.75


@interface DVController(PRIVATE)
- (void)timedUpdate:(NSTimer *)timer;
- (void)partyHard;
@end

#pragma mark -

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent,void *userData)
{
	[[NSApplication sharedApplication] terminate:nil];
	return noErr;
}


#pragma mark -

@implementation DVController

/**
 * Initalize our data members; set up the window and view.
 */
- (void)awakeFromNib
{
	//32x32 is an arbitrary number, 1x1 doesn't seem to let it resize. This works, I'm not complaining. 
	panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0,0,32,32) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	//We want this transparent, slightly
	[panel setOpaque:NO];
	[panel setBackgroundColor:[NSColor clearColor]];
	[panel setAlphaValue:DV_WINDOW_TRANSPARENCY];

	//We want to show this ALL the time
	[panel setHidesOnDeactivate:NO];
	[panel setFloatingPanel:YES];
	
	//Let's put a little boogie in it, shall we?
	view = [[DVContentView alloc] initWithFrame:[panel frame]];
	[panel setContentView:view];
	
	//Register the Hotkeys. This code is ganked from Dustin Bachrach. Press command-opt-F4 to quit.
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	
	InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
	gMyHotKeyID.signature='ovar';
	gMyHotKeyID.id=1;

	RegisterEventHotKey(0x76, cmdKey+optionKey, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
	
	//If you got it, flaunt it
	[panel orderFront:nil];
	
	//And so it begins...
	[self timedUpdate:nil];

}

/**
 * Deallocate our memory.
 */
- (void)dealloc
{
	//Clean up after ourselves
	[panel release];
	[view release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private


/**
 * @brief Called often, updates the window and tracks the mouse
 *
 * @param timer The NSTimer object passed by -scheuledTimerWithTimeInterval:target:selector:userinfo:repeats:. May be nil.
 *
 * This method doesn't actually do anything, other than poll every 0.1 seconds. It hands the processing off to -partyHard.
 */
 
- (void)timedUpdate:(NSTimer *)timer
{
	//YEAHHH!
	[self partyHard];

	//DO IT AGAIN!!
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timedUpdate:) userInfo:nil repeats:NO];
}

/**
 * @brief Most of the actual processing, mouse tracking, and view updating.
 *
 * This is the bulk of our polling code. Also contains logic for positioning the window/overlay on-screen.
 */
- (void)partyHard
{
	//Get the mouse location from Carbon
	Point carbonPoint;
	GetMouse(&carbonPoint);
	
	//Retrieve the data from the Accessibility API
	NSDictionary *dict = [DVInfo getInfoForPoint:NSMakePoint(carbonPoint.h, carbonPoint.v)];
	NSString *title = [dict valueForKey:DV_INFO_WINDOW_TITLE];
	NSString *name = [dict valueForKey:DV_INFO_APP_NAME];
	
	//nil values are bad; so we use @"" instead.
	[view setWindowTitle:(title ? title : @"")];
	[view setAppName:(name ? name : @"")];
	
	//This logic makes sure that the overlay stays onscreen. It's annoying compounded by the fact that the origin
	//is in the bottom left for Cocoa, and the top right for Carbon. It is untested on multiple monitors, and probably
	//won't work very well.
	NSSize requestedSize = [view requestedSize];
	
	int uncheckedX = carbonPoint.h + DV_WINDOW_X_OFFSET;
	int uncheckedY = [[NSScreen mainScreen] frame].size.height - carbonPoint.v - requestedSize.height - DV_WINDOW_Y_OFFSET;
	int maxX = [[NSScreen mainScreen] visibleFrame].size.width - requestedSize.width;
	int maxY = [[NSScreen mainScreen] visibleFrame].size.height + requestedSize.height;
	int minX = [[NSScreen mainScreen] visibleFrame].origin.x;
	int minY = [[NSScreen mainScreen] visibleFrame].origin.y;
	
	//Now that we've pre-figured all the values, run them through the min and max macros, and then set the frame.
	NSRect newFrame = NSMakeRect(MAX(MIN(uncheckedX, maxX), minX),
								 MAX(MIN(uncheckedY, maxY), minY), 
								 requestedSize.width, 
								 requestedSize.height);
	[panel setFrame:newFrame display:YES];
}

@end
