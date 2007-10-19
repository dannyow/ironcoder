//
//  PixureImage.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// implementation note: all colors are in device rgb color space

// PixureImage - an image container                  
// contains an image that a pixuresytem compares its population against
@interface PixureImage : NSObject {
//	NSImage* image;
	
//	NSBitmapImageRep* bitmapRep;

	NSBitmapImageRep* bitmap;
	
	NSMutableDictionary* colorCache;
}

- (NSColor*)colorAtX:(unsigned int)x y:(unsigned int)y;

- (id)initWithImage:(NSImage*)inImage;

//- (NSImage*)image;
- (void)setImage:(NSImage*)inImage;

- (NSSize)size;

@end
