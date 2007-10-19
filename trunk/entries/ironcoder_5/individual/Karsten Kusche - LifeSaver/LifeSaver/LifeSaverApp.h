//
//  LifeSaverApp.h
//  LifeSaver
//
//  Created by Karsten Kusche on 31.03.07.
//  Copyright 2007 briksoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferenceController.h"
#import "IdleChecker.h"
#import "HotKey.h"


@interface LifeSaverApp : NSApplication {
	IBOutlet PreferenceController* prefController;

	NSStatusItem* statItem;
	NSMutableArray* saverWindows;
	IdleChecker* idleChecker;
	HotKey* hotKey;
	EventHotKeyRef hotKeyRef;
	NSMenu* menu;
}

- (void)changeShortcut:(id)sender;
- (HotKey*)hotKey;

@end
