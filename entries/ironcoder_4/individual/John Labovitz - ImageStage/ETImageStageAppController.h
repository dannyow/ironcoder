//
//  ETImageStageAppController.h
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "ETStageView.h"
#import "ETImageGrabber.h"

@interface ETImageStageAppController : NSObject {
	
	ETImageGrabber *_imageGrabber;
	NSString *_status;
	NSTimer *_downloadWatchdogTimer;

	IBOutlet ETStageView *stageView;
}

- (ETImageGrabber *)imageGrabber;
- (void)setImagegrabber:(ETImageGrabber *)imageGrabber;

- (NSString *)status;
- (void)setStatus:(NSString *)status;

@end
