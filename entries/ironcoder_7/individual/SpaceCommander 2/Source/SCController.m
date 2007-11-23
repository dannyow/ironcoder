//
//  SCController.m
//  SpaceCommander
//
//  Created by Zac White on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SCController.h"


@implementation SCController

- (void)awakeFromNib{
	//[self startObserving];
	//[welcomeWindow center];
	//[welcomeWindow makeKeyAndOrderFront:self];
	
	//SCWindow *window = [[SCWindow alloc] initWithContentRect:NSMakeRect(500,500,50,50) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	//[window setImage:[NSImage imageNamed:@"background.png"] withRotation:45];
	//[window orderFront:self];
	//[window setBackgroundColor:[NSColor redColor]];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChange:) name:@"com.apple.switchSpaces" object:nil];
	
	//NSMutableArray *array = [self getWindowList];
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"SpaceCommander"];
	[statusItem setMenu:menu];
	[statusItem setEnabled:YES];
	[statusItem setImage:[NSImage imageNamed:@"rocket_small.png"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"rocket_small.png"]];
	
	[self registerGlobalHotkeys];
}

OSStatus HotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData){
	EventHotKeyID hkCom;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkCom),NULL,&hkCom);
	int l = hkCom.id;
	NSLog(@"l: %d", l);
	switch (l) {
		case 1: //left
			//[[SCSpaceController instance] left];
			//[[SCSpaceController instance] showBezelForWindowList];
			break;
		case 2: //right
			//[[SCSpaceController instance] right];
			break;
		case 3: //down
			//[[SCSpaceController instance] down]; 
			break;
		case 4: //up
			//[[SCSpaceController instance] up];
			break;
		case 5:
			[[SCSpaceController instance] showBezelForWindowList];
			break;
		default: //we don't handle this event.
			NSLog(@"ERROR");
	}
	return noErr;
}

- (void)registerGlobalHotkeys{
	//information gathered from: http://dbachrach.com/blog/2005/11/28/program-global-hotkeys-in-cocoa-easily/
	
	//Register the Hotkeys
	EventHotKeyRef gHotKeyRef;
	EventHotKeyID gLeftHotKeyID, gRightHotKeyID, gDownHotKeyID, gUpHotKeyID, gHoldHotKeyID;
	
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	
	InstallApplicationEventHandler(&HotKeyHandler,1,&eventType,NULL,NULL);
	
	gLeftHotKeyID.signature='htk1';
	gLeftHotKeyID.id=1;
	
	RegisterEventHotKey(123, controlKey+optionKey, gLeftHotKeyID, GetApplicationEventTarget(), 0, &gHotKeyRef);
	
	gRightHotKeyID.signature='htk2';
	gRightHotKeyID.id=2;
	
	RegisterEventHotKey(124, controlKey+optionKey, gRightHotKeyID, GetApplicationEventTarget(), 0, &gHotKeyRef);
	
	gDownHotKeyID.signature='htk3';
	gDownHotKeyID.id=3;
	
	RegisterEventHotKey(125, controlKey+optionKey, gDownHotKeyID, GetApplicationEventTarget(), 0, &gHotKeyRef);
	
	gUpHotKeyID.signature='htk4';
	gUpHotKeyID.id=4;
	
	RegisterEventHotKey(126, controlKey+optionKey, gUpHotKeyID, GetApplicationEventTarget(), 0, &gHotKeyRef);
	
	gHoldHotKeyID.signature='htk5';
	gHoldHotKeyID.id=5;
	
	RegisterEventHotKey(50, controlKey, gHoldHotKeyID, GetApplicationEventTarget(), 0, &gHotKeyRef);
}

- (void)handleChange:(NSNotification *)not{
	//int newSpace = [[not object] intValue] + 1;
	//[controller setCurrentSpace:newSpace];
	
	NSImage *newImage = [NSImage imageNamed:@"rocket_small.png"];
	
	[newImage lockFocus];
	[[not object] drawAtPoint:NSMakePoint(0,0) withAttributes:nil];
	[newImage unlockFocus];
	
	[statusItem setImage:newImage];
	[statusItem setAlternateImage:newImage];
}

- (IBAction)getIt:(id)sender{
	
	//NSArray *windowList = [[SCSpaceController instance] getWindowList];
		//[[SCSpaceController instance] setCurrentSpace:[[info objectForKey:@"currentSpace"] intValue]];
	//[[SCSpaceController instance] setColumns:3];
	//[[SCSpaceController instance] setRows:2];
	//[[SCSpaceController instance] setCurrentSpace:[[windowList objectAtIndex:0] workspace]];
	[[SCSpaceController instance] showBezelForWindowList];
	
	//NSLog(@"poo");
	//[[welcomeWindow animator] setFrame:NSMakeRect(0,0, [welcomeWindow frame].size.width, [welcomeWindow frame].size.height) display:YES];
	
	//[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.switchSpaces" object:@"0"];
}

@end
