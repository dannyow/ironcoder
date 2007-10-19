//
//  HiddenWindow.h
//  Camouflage
//
//  Created by Karsten Kusche on 20.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ApplicationServices/ApplicationServices.h>
#import "ScreenSaverFramework.h"
typedef int CGSConnectionID;
typedef int CGSWindowID;

extern CGSConnectionID _CGSDefaultConnection();
extern OSStatus CGSGetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);
extern OSStatus CGSClearWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);

extern OSStatus CGSConnectionGetPID(const CGSConnectionID cid, pid_t *pid, CGSWindowID wid);


@interface HiddenWindow : ScreenSaverWindow {
	NSNumber* screenID;
	NSDictionary* infoDict;
	NSDate* lastModified;
}

+(id)windowForScreen: (NSScreen*)screen;
+ (id)windowForScreenWithID: (CGDirectDisplayID) display;

- (void)setScreenId:(NSNumber*) screenID;
- (NSNumber*)screenID;
- (void)updateDisplay;
- (void)setupScreenSaver;
@end
