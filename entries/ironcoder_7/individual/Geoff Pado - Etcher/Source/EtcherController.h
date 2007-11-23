//
//  EtcherController.h
//  Etcher
//
//  Created by Geoff Pado on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "EtcherView.h"
#import "EtcherWindow.h"
#import "motion.h"

@interface EtcherController : NSObject {
	NSWindow *etcherWindow;
	NSImageView *leftKnob;
	NSImageView *rightKnob;
	EtcherView *etcherView;
	IBOutlet NSWindow *helpWindow;
	int macType;
	int structSize;
	BOOL isShaking;
}

- (BOOL)shakeWindow;
- (IBAction)clearEtcher:(id)sender;
- (IBAction)showHelp:(id)sender;
- (void)spinDial:(NSString *)dial distance:(int)distance;

@end
