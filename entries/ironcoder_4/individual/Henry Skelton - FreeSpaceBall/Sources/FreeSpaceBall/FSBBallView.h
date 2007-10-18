//
//  FSBBallView.h
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 Henry Skelton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSBMemoryMonitor.h"
#import "FSBAppController.h"
#import "globals.h"
#import <QuartzCore/QuartzCore.h>

#define NSRectToCGRect(r) CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height)

/*!
	@class			FSBBallView
	@abstract		This object controls the indicator.
	@discussion		This object controls the ball image that indicates resource usage.
*/
@interface FSBBallView : NSView {
	//The main image used to display memory usage
	CIImage* ballImage;
	CIImage* outlineImage;
	CIFilter* ballImageFilter;
	BOOL firstDraw;
	CGRect ballImageExtent;
	int draws;
}

/*!
	@method			initWithFrame
	@discussion		Initializes an instance of this class.
	@result			Returns instance upon success (or nil otherwise).
*/
- (id)initWithFrame:(NSRect)frame;

/*!
	 @method			drawRect
	 @discussion		Draws the image that shows resource usage.
	 @result			Draws the image with proper criteria to show resource usage.
*/
-(void)drawRect;

/*!
	 @method			memoryUsageChanged
	 @discussion		Responds to a change in the amount of memory used.
	 @result			The memory indicator is changed in response and in proportion to the change in memory use.
 */
- (void)memoryUsageChanged:(NSNotification *)notification;

@end
