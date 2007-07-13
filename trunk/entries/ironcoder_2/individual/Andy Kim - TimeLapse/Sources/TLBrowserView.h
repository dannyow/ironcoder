//
//  TLBrowserView.h
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MIN_ZOOM_FACTOR 25
#define MAX_ZOOM_FACTOR 100

@interface TLBrowserView : NSView
{
	float mZoomFactor;
// 	NSMutableDictionary *mImageCache;

	// Size of each thumbnail
	NSSize mThumbSize;
}

- (float)zoomFactor;
- (void)setZoomFactor:(float)zoomFactor;
	
- (void)recalculateBounds;

@end
