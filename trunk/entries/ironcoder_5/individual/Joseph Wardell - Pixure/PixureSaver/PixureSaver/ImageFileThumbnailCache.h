//
//  ImageFileThumbnailCache.h
//  PixureSaver
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImageFileThumbnailCache : NSObject {
	NSMutableDictionary* cachedThumbs;
}
- (NSImage*)thumbnailForPath:(NSString*)inPath;
@end
