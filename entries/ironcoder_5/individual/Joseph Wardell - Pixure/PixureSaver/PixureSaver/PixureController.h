//
//  PixureController.h
//  PixureSaver
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PixureSystem;
@class ImageFileThumbnailCache;

@interface PixureController : NSObject {

	PixureSystem* system;
	BOOL evolving;
	NSString* sourcePath;
	
	NSLock* evolutionLock;

	unsigned int pictureIndex;
	
	NSArray* picturePaths;
	ImageFileThumbnailCache* thumbnails;
}

+ (PixureController*)PixureController;


- (void)startEvolving;
- (void)stopEvolving;

- (PixureSystem*)system;

- (NSImage*)imageToShow;

- (NSString *)sourcePath;
- (void)setSourcePath:(NSString *)inSourcePath;

- (unsigned int)pictureIndex;
- (void)setPictureIndex:(unsigned int)inPictureIndex;

- (NSImage*)thumbnailForPath:(NSString*)inPath;
- (NSTimeInterval)timeBetweenRotations;
- (NSImage*)imageToShow;
- (NSString*)pathToSourceFile;

- (void)startAnimation;
- (void)stopAnimation;

@end
