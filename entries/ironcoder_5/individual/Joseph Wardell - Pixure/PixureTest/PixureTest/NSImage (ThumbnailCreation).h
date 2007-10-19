//
//  NSImage (ThumbnailCreation).h
//  ImageColorExplorer_@
//
//  Created by Joseph Wardell on 2/18/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (ThumbnailCreation)

+ (NSImage*)thumbnalImageForIconAtPath:(NSString*)inPath withSize:(int)maxWidthOrHeight;

@end
