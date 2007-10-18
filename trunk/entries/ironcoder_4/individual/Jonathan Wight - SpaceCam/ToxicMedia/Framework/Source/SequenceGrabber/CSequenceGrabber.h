//
//  CSequenceGrabber.h
//  SequenceGrabber
//
//  Created by Jonathan Wight on 10/19/2004.
//  Copyright 2004 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuickTime/QuickTime.h>

@class CCarbonComponentInstance;
@class CSequenceGrabberVideoChannel;
@class CSequenceGrabberSoundChannel;

@interface CSequenceGrabber : NSObject <NSCoding> {
	BOOL writeToFile;
	NSString *outputPath;

	CCarbonComponentInstance *sequenceGrabber;
	CSequenceGrabberVideoChannel *videoChannel;
	CSequenceGrabberSoundChannel *soundChannel;
	
	BOOL isStarted;
	int pauseCount;
	NSTimer *timer;
}

- (void)imageAvailable;
- (CIImage *)image;

- (BOOL)writeToFile;
- (void)setWriteToFile:(BOOL)inWriteToFile;

- (NSString *)outputPath;
- (void)setOutputPath:(NSString *)inOutputPath;

- (SeqGrabComponent)component;

- (CSequenceGrabberVideoChannel *)videoChannel;
- (void)setVideoChannel:(CSequenceGrabberVideoChannel *)inVideoChannel;

- (CSequenceGrabberSoundChannel *)soundChannel;
- (void)setSoundChannel:(CSequenceGrabberSoundChannel *)inSoundChannel;

- (NSData *)settings;
- (void)setSettings:(NSData *)inSettings;

- (BOOL)isStarted;

- (IBAction)start:(id)inSender;
- (IBAction)stop:(id)inSender;

- (BOOL)isPaused;

- (IBAction)pause:(id)inSender;
- (IBAction)resume:(id)inSender;

@end

#pragma mark -

extern NSString *CSequenceGrabberImageAvailableNotification /* = @"CSequenceGrabberImageAvailableNotification" */;
extern NSString *CSequenceGrabberWillStartNotification /* = @"CSequenceGrabberWillStartNotification" */;
extern NSString *CSequenceGrabberDidStartNotification /* = @"CSequenceGrabberDidStartNotification" */;
extern NSString *CSequenceGrabberWillStopNotification /* = @"CSequenceGrabberWillStopNotification" */;
extern NSString *CSequenceGrabberDidStopNotification /* = @"CSequenceGrabberDidStopNotification" */;
