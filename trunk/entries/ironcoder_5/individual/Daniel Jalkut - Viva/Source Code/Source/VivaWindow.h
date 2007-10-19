//
//  VivaWindow.h
//  VivaApp
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScreenSaverHack.h"

@interface VivaWindow : ScreenSaverWindow
{
}

- (id) initWithContentRect:(NSRect)contentRect;

- (NSArray *) screensaverNames;
- (void) setScreensaverNames: (NSArray *) theScreensaverNames;

- (int) visibleScreensaverCount;
- (void) setVisibleScreensaverCount: (int) theVisibleScreensaverCount;

@end
