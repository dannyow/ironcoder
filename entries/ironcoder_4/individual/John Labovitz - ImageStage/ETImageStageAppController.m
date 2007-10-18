//
//  ETImageStageAppController.m
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import "ETImageStageAppController.h"


@interface ETImageStageAppController(ETImageStageAppControllerPrivate)

- (void)fillQueue;

@end


@implementation ETImageStageAppController


- (void)awakeFromNib {
	
	[self setImagegrabber:[[[ETImageGrabber alloc] initWithQuery:@"space"] autorelease]];
	[[self imageGrabber] setDelegate:self];
	
	[self fillQueue];
	
	_downloadWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															  target:self
															selector:@selector(downloadWatchdogDidFire:)
															userInfo:nil
															 repeats:YES];
}


#pragma mark Properties


- (ETImageGrabber *)imageGrabber { return [[_imageGrabber retain] autorelease]; }
- (void)setImagegrabber:(ETImageGrabber *)imageGrabber { if (imageGrabber != _imageGrabber) { [_imageGrabber release]; _imageGrabber = [imageGrabber retain]; } }

- (NSString *)status { return [[_status retain] autorelease]; }
- (void)setStatus:(NSString *)status { if (status != _status) { [_status release]; _status = [status retain]; } }


#pragma mark Methods


- (void)downloadWatchdogDidFire:(NSTimer *)timer {
		
	[self fillQueue];
}


- (void)fillQueue {
	
	//;;NSLog(@"fillQueue: queue = [%d], connections = [%d]", [[stageView imageQueue] count], [[[self imageGrabber] connections] count]);
	
	if ([[stageView imageQueue] count] < 5 && [[[self imageGrabber] connections] count] < 5) {
		
		[[self imageGrabber] grabImage];
	}
}


#pragma mark Delegate methods


- (void)imageWillDownload:(NSDictionary *)userInfo {
	
	[self setStatus:[NSString stringWithFormat:@"Downloading %@ (%@ bytes)...", [userInfo objectForKey:@"url"], [userInfo objectForKey:@"size"]]];
}


- (void)imageDidDownload:(NSDictionary *)userInfo {
	
	[self setStatus:[NSString stringWithFormat:@"Downloaded %@", [userInfo objectForKey:@"url"]]];
	
	NSImage *image = [userInfo objectForKey:@"image"];
	
	[stageView queueImage:image];
	
	[self fillQueue];
}


- (void)imageDidFailToDownload:(NSDictionary *)userInfo {
	
	[self setStatus:[NSString stringWithFormat:@"Failed to download %@", [userInfo objectForKey:@"url"]]];
	
	[self fillQueue];
}


@end