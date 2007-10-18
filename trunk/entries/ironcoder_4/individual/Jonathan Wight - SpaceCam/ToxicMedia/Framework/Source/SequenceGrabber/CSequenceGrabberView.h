//
//  CSequenceGrabberView.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/12/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CFilteringCoreImageView.h"

@class CSequenceGrabber;

@interface CSequenceGrabberView : CFilteringCoreImageView {
	IBOutlet CSequenceGrabber *outletSequenceGrabber;
	NSObjectController *controller;
}

- (CSequenceGrabber *)sequenceGrabber;

- (IBAction)start:(id)inSender;
- (IBAction)stop:(id)inSender;

- (IBAction)pause:(id)inSender;
- (IBAction)resume:(id)inSender;

- (IBAction)runVideoChannelSettingsDialog:(id)inSender;
- (IBAction)runSoundChannelSettingsDialog:(id)inSender;

- (IBAction)saveSettings:(id)inSender;
- (IBAction)loadSettings:(id)inSender;

@end
