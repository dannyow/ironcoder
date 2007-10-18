//
//  CFlickrFeed.h
//  Space
//
//  Created by Jonathan Wight on 10/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	FlickrFeedMode_Idle,
	FlickrFeedMode_DownloadingFeed,	
	FlickrFeedMode_DownloadingImage,	
	} EFlickrFeedMode;

@interface CFlickrFeed : NSObject {
	EFlickrFeedMode mode;
	NSImage *image;
	NSMutableArray *imageUrls;
	NSMutableArray *images;
	NSMutableData *data;
	NSURLConnection *connection;
}

- (EFlickrFeedMode)mode;
- (void)setMode:(EFlickrFeedMode)inMode;

- (NSImage *)image;
- (void)setImage:(NSImage *)inImage;

- (CIImage *)coreImage;

@end
