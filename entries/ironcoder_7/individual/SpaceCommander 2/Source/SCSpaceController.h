//
//  SCSpaceController.h
//  SpaceCommander
//
//  Created by Zac White on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SCWindow.h"

@interface SCSpaceController : NSObject {
	int cols;
	int rows;
	
	BOOL showWindows;
	
	NSMutableArray *windows;
	
	int current;
}

+ (SCSpaceController *)instance;
- (void)setColumns:(int)columns;
- (void)setRows:(int)rowCount;
- (void)setCurrentSpace:(int)currentSpace;

- (NSDictionary *)getCurrentSpaceInfo;

//control of spaces.
- (void)left;
- (void)right;
- (void)down;
- (void)up;

- (NSPoint)positionForWorkspace:(int)workspace;
- (SCWindow *)bezelForWindowFrame:(CGRect)frame inWorkspace:(int)workspace withApplicationPath:(NSString *)path;
- (NSMutableArray *)getWindowList;

//hide/show the bezel
- (void)showBezelForWindowList;
- (void)hideBezel;

@end
