//
//  CMyController.h
//  SequenceGrabber
//
//  Created by Jonathan Wight on 10/19/2004.
//  Copyright 2004 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSequenceGrabber;
@class CFilteringCoreImageView;

@interface CMyController : NSObject {
	IBOutlet NSWindow *outletWindow;

	IBOutlet CFilteringCoreImageView *image1;
	IBOutlet CFilteringCoreImageView *image2;
	IBOutlet CFilteringCoreImageView *image3;
	IBOutlet CFilteringCoreImageView *image4;
	IBOutlet CFilteringCoreImageView *image5;

	CSequenceGrabber *sequenceGrabber;
}

- (IBAction)actionStart:(id)inSender;
- (IBAction)actionStop:(id)inSender;
- (IBAction)actionConfigure:(id)inSender;

@end
