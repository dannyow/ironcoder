//
//  LifeSaverApp.m
//  LifeSaver
//
//  Created by Karsten Kusche on 31.03.07.
//  Copyright 2007 briksoftware.com. All rights reserved.
//

#import "LifeSaverApp.h"
#import "HiddenWindow.h"
#import "StatusItemExtension.h"

enum {
	// NSEvent subtypes for hotkey events (undocumented).
	kEventHotKeyPressedSubtype = 6,
	kEventHotKeyReleasedSubtype = 9,
};

@implementation LifeSaverApp

- (NSArray*)saverWindows
{
	return saverWindows;
}

- (void)activateMe:(id)sender
{
//	NSLog(@"activating: %@",[[self saverWindows] description]);
	[self activateIgnoringOtherApps:YES];
	[[self saverWindows] makeObjectsPerformSelector:@selector(makeKeyAndOrderFront:) withObject:nil];
	[NSCursor hide];
}

- (void)saverWindows:(NSArray*)array
{
	if (saverWindows == nil)
	{
		saverWindows = [[NSMutableArray array] retain];
	}
	[saverWindows setArray:array];
}

- (void)createNewWindows
{
	NSMutableArray* windows = [NSMutableArray array];
	
	NSEnumerator* screens = [[NSScreen screens] objectEnumerator];
	NSScreen* screen;
	
	while (screen = [screens nextObject])
	{
		[windows addObject:[HiddenWindow windowForScreen:screen]];
	}
	[self saverWindows:windows];
	[[self saverWindows] makeObjectsPerformSelector:@selector(close)];
}

- (void)registerHotKey
{
	hotKey = [[HotKey hotKeyFromArray:[prefController hotKeyArray]] retain];
	NSLog(@"registering hotkey: %@",[hotKey description]);
	if (hotKey)
	{
		hotKeyRef = [hotKey setWithID:1];
	}
}

- (void)unregisterHotKey
{
	[hotKey unRegister];
}

- (NSArray*)hotKeyArray
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"hotKey"];
}

- (HotKey*)hotKey
{
	return hotKey;
}
- (void)showPrefs:(id)sender
{
	[prefController showWindow:sender];
	[self activateIgnoringOtherApps:YES];
}

- (void)initStatusMenu
{
	menu = [[NSMenu alloc] initWithTitle:@"LifeSaver Menu"];
	[menu addItemWithTitle:@"Activate" action:@selector(activateMe:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Show Prefs" action:@selector(showPrefs:) keyEquivalent:@""];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}

- (void)showMenu:(id)sender
{
	[NSMenu popUpContextMenu:menu 
				   withEvent:[NSApp currentEvent] 
					 forView:nil];
}

- (void)finishLaunching
{
	NSLog(@"opening window");
	[self hide:nil];
	statItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:28] retain];
	[statItem setHighlightMode:YES];
	[statItem setImage:[NSImage imageNamed:@"LifeSaver_MenuItem"]];
	[statItem setAction:@selector(activateMe:)];
	[statItem setTarget:self];
	[statItem sendActionOn:NSRightMouseDown];
	[self initStatusMenu];
	[statItem setMenu:menu];
	[self createNewWindows];
	[self registerHotKey];
	
	[self setDelegate:self];
	idleChecker = [IdleChecker send:@selector(activateMe:) to:self with:nil afterIdleTimeOf:[prefController idleTime]*60];
}

- (void)changeShortcut:(id)sender
{
	[self unregisterHotKey];
	[self activateIgnoringOtherApps:YES];
	hotKey = [prefController newHotKey];
	if ([[[hotKey asArray] objectAtIndex:1] intValue] == 0x35)
	{
		//esc pressed
		[hotKey release];
		hotKey = nil;
		[prefController hotKeyArray: nil];
	}
	else
	{
		[prefController hotKeyArray: [hotKey asArray]];
	}
	[prefController showShortcut];
	[self registerHotKey];
}

- (void)sendEvent:(NSEvent*)theEvent
{
	if ([theEvent type] == NSSystemDefined && [theEvent subtype] == kEventHotKeyReleasedSubtype)
	{
		if ((EventHotKeyRef)[theEvent data1] == hotKeyRef)
		{
			if ([self isActive])
			{
				[self hide:nil];
			}
			else
			{
				[self activateMe:nil];
			}
		}
	}
	else if ([theEvent type] == NSRightMouseDown && NSPointInRect([NSEvent mouseLocation],[statItem hackFrame]))
	{
		[self activateMe:nil];
	}
	
/*	if ((([theEvent type] == NSMouseMoved && [self noUnintendedMoveInEvent:theEvent]) || ([theEvent type] == NSKeyDown)) && ![prefWindow isVisible])
	{
		//		NSLog(@"hiding because of event: %@",[theEvent description]);
		[self deactivateIt];
		return;
	}
*/
	else
	{
		[super sendEvent:theEvent];
	}
}

- (void)hide:(id)sender
{
	[NSCursor unhide];
	[[self saverWindows] makeObjectsPerformSelector:@selector(close)];
	[super hide:sender];
}

- (void)applicationWillResignActive:(NSNotification *)aNotification
{
	if ([[[self saverWindows] lastObject] isVisible])
	{
		[self hide:nil];
	}
}
@end
