//
//  IronDazzleController.m
//  IronDazzle
//
//  Created by Tom Harrington on 7/21/06.
//  Copyright 2006 Tom Harrington. All rights reserved.
//

/*
 This source code is open sourced and may be used in any way whatsoever, except for purposes of making fun of the author.
 May your favorite deity or deities help you if you actually choose to do this.
 */
#import "IronDazzleController.h"
#import "IronDazzleView.h"
#import <Carbon/Carbon.h>

static NSRect screenFrame;
const float vectorMax = 5.0;

CGEventRef printEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
	// kCGMouseEventDeltaX
	NSPanel *dazzlePanel = (NSPanel *)refcon;
	IronDazzleView *dazzleView = [dazzlePanel contentView];
	
	switch(type) {
		CGPoint mouseLocation;
		double deltaX, deltaY;

		case kCGEventMouseMoved:
			mouseLocation = CGEventGetLocation(event);
			
			deltaX = CGEventGetDoubleValueField(event, kCGMouseEventDeltaX);
			deltaY = CGEventGetDoubleValueField(event, kCGMouseEventDeltaY);
			NSLog(@"Mouse point: (%f, %f) delta = (%f, %f)", mouseLocation.x, mouseLocation.y, deltaX, deltaY);
			
			NSRect dazzlePanelFrame = [dazzlePanel frame];
			dazzlePanelFrame.origin.x = mouseLocation.x - (dazzlePanelFrame.size.width / 2);
			// this won't work right on multi-display systems
			dazzlePanelFrame.origin.y =  screenFrame.size.height - mouseLocation.y - (dazzlePanelFrame.size.height / 2);
			[dazzlePanel setFrame:dazzlePanelFrame display:YES];
			
			if ((deltaX != 0.0) || (deltaY != 0.0)) {
				CGPoint vector;
				
				if (deltaX > 0.0)
					vector.x = (deltaX > vectorMax) ? -vectorMax : -deltaX;
				else
					vector.x = (deltaX < -vectorMax) ? vectorMax : -deltaX;
				if (deltaY > 0.0)
					vector.y = (deltaY > vectorMax) ? vectorMax : deltaY;
				else
					vector.y = (deltaY < -vectorMax) ? -vectorMax : deltaY;
				[dazzleView addConfettiItemWithVector:vector];
			}
			break;
		default:
			NSLog( @"Got event of type %d\n", type );
	}
	return event;
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent,void *userData)
{
	[[NSApplication sharedApplication] terminate:nil];
	return noErr;
}

@implementation IronDazzleController

- (void)awakeFromNib
{
    CFMachPortRef eventPort;
    CFRunLoopSourceRef  eventSrc;
    CFRunLoopRef    runLoop;

	srandom(time(NULL));
	
	dazzlePanel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0,0,800,800) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	//We want this transparent, slightly
	[dazzlePanel setOpaque:NO];
	[dazzlePanel setBackgroundColor:[NSColor clearColor]];
	[dazzlePanel setAlphaValue:1.0];
	
	//We want to show this ALL the time
	[dazzlePanel setHidesOnDeactivate:NO];
	[dazzlePanel setFloatingPanel:YES];
	
	// Don't let confetti items get in the way of doing other things
	[dazzlePanel setIgnoresMouseEvents:YES];
	
	dazzleView = [[IronDazzleView alloc] initWithFrame:[dazzlePanel frame]];
	[dazzlePanel setContentView:dazzleView];
	
	[dazzlePanel orderFront:nil];
	
    eventPort = CGEventTapCreate(kCGSessionEventTap,
								 kCGHeadInsertEventTap,
								 kCGEventTapOptionListenOnly,
								 CGEventMaskBit(kCGEventMouseMoved),
								 printEventCallback,
								 dazzlePanel );
    if ( eventPort == NULL )
    {
        printf( "NULL event port\n" );
        exit( 1 );
    }
	
    eventSrc = CFMachPortCreateRunLoopSource(NULL, eventPort, 0);
    if ( eventSrc == NULL )
        printf( "No event run loop src?\n" );
	
    runLoop = CFRunLoopGetCurrent(); //[[NSRunLoop currentRunLoop] getCFRunLoop];
    if ( runLoop == NULL )
        printf( "No run loop?\n" );
	
    CFRunLoopAddSource(runLoop,  eventSrc, kCFRunLoopDefaultMode);
	
	NSScreen *mainScreen = [NSScreen mainScreen];
	screenFrame = [mainScreen frame];
	
	//Register the Hotkeys. This code is ganked from Dustin Bachrach. Press command-opt-F5 to quit.
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	
	InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
	gMyHotKeyID.signature='ovar';
	gMyHotKeyID.id=1;
	
	RegisterEventHotKey(0x60, cmdKey+optionKey, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
	
}

@end
