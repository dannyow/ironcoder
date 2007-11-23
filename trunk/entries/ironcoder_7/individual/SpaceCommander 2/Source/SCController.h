//
//  SCController.h
//  SpaceCommander
//
//  Created by Zac White on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "SCWindowInfo.h"
#import "SCSpaceController.h"

@interface SCController : NSObject {
	IBOutlet NSWindow *welcomeWindow;

	NSArrayController *arrayController;
		
	NSStatusItem *statusItem;
	
	IBOutlet NSMenu *menu;
}

- (void)registerGlobalHotkeys;

- (IBAction)getIt:(id)sender;
@end
