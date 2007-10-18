//
//  CMyController.h
//  Space
//
//  Created by Jonathan Wight on 10/28/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>
#import "CSequenceGrabber.h"
#import "CCoreImageView.h"

typedef enum {
	ImageMode_Inactive,
	ImageMode_Gathering,
	ImageMode_Displaying,
	} EImageMode;

@class CFlickrFeed;
@class CImageAverager;

@interface CMyController : NSObject {
	EImageMode imageMode;
	CIImage *sourceImage;
	CIImage *backgroundImage;
	CIImage *scenaryImage;
	CIImage *outputImage;
	CIFilter *backgroundReplacerFilter;

	CFlickrFeed *flickrFeed;
	CImageAverager *imageAverager;

	IBOutlet CCoreImageView *outletCoreImageView;
	IBOutlet CSequenceGrabber *outletSequenceGrabber;	
}

- (EImageMode)imageMode;
- (void)setImageMode:(EImageMode)inImageMode;

- (CIImage *)sourceImage;
- (void)setSourceImage:(CIImage *)inSourceImage;

- (CIImage *)backgroundImage;
- (void)setBackgroundImage:(CIImage *)inBackgroundImage;

- (CIImage *)scenaryImage;
- (void)setScenaryImage:(CIImage *)inScenaryImage;

- (CIImage *)outputImage;
- (void)setOutputImage:(CIImage *)inOutputImage;

- (CIFilter *)backgroundReplacerFilter;

- (IBAction)actionGatherBackground:(id)inSender;

@end
