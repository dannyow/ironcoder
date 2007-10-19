//
//  ImageFileThumbnailCache.m
//  PixureSaver
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "ImageFileThumbnailCache.h"
#import "NSImage (ThumbnailCreation).h"


@implementation ImageFileThumbnailCache

- (void)dealloc
{
	[cachedThumbs release];

	[super dealloc];
}


- (NSMutableDictionary*)cachedThumbs;
{
	if (nil == cachedThumbs)
		cachedThumbs = [[NSMutableDictionary alloc] init];
		
	return cachedThumbs;
}

- (void)findThumbForFile:(NSString*)inFilePath;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSImage* foundImage = [NSImage thumbnalImageForIconAtPath:inFilePath withSize:89.0];
	if (nil != foundImage)
		[[self cachedThumbs] setObject:foundImage forKey:inFilePath];
	
	[pool release];
}

- (NSImage*)thumbnailForPath:(NSString*)inPath;
{
	NSImage* outImage = [[self cachedThumbs] objectForKey:inPath];
	if (nil != outImage)
		return outImage;
		
	[NSThread detachNewThreadSelector:@selector(findThumbForFile:) toTarget:self withObject:inPath];
	
	return nil;
}

@end
