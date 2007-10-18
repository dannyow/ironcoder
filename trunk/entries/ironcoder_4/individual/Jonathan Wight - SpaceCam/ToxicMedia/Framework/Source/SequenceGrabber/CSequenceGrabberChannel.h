//
//  CSequenceGrabberChannel.h
//  SequenceGrabber
//
//  Created by Jonathan Wight on 08/06/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuickTime/QuickTime.h>

@class CSequenceGrabber;

extern NSString *CSequenceGrabberChannelSettingsDidChangeNotification /* = @"CSequenceGrabberChannelSettingsDidChangeNotification" */;

@interface CSequenceGrabberChannel : NSObject {
	CSequenceGrabber *sequenceGrabber; // Not retained.
	SGChannel channel;
}

- (id)init;
- (id)initWithSequenceGrabber:(CSequenceGrabber *)inSequenceGrabber;

- (void)invalidate;

- (CSequenceGrabber *)sequenceGrabber;

- (SGChannel)channel;
- (void)setChannel:(SGChannel)inChannel;

- (NSString *)deviceName;

- (NSString *)inputName;

- (IBAction)runSettingsDialog:(id)inSender;

- (void)sequenceGrabberWillChangeSettings;
- (void)sequenceGrabberDidChangeSettings;

- (void)sequenceGrabberWillStart:(NSNotification *)inNotification;
- (void)sequenceGrabberWillStop:(NSNotification *)inNotification;

@end