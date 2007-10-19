//
//  NSImage (ThumbnailCreation).m
//  ImageColorExplorer_@
//
//  Created by Joseph Wardell on 2/18/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "NSImage (ThumbnailCreation).h"


@implementation NSImage (ThumbnailCreation)


+ (NSImage*)thumbnalImageForIconAtPath:(NSString*)inPath withSize:(int)maxWidthOrHeight;
{
	NSURL *url = [NSURL fileURLWithPath:inPath];
	
	CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url,NULL);
	if (source)
	{
		if (!CGImageSourceGetCount(source))
		{
			CFRelease(source);
			return nil; // somehow we loaded the source but it isn't valid
		}
		
		NSDictionary* thumbOpts = [NSDictionary dictionaryWithObjectsAndKeys:
			(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
			(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
			[NSNumber numberWithInt:maxWidthOrHeight],
			(id)kCGImageSourceThumbnailMaxPixelSize, 
			nil];
		
		CGImageRef theCGImage = CGImageSourceCreateThumbnailAtIndex(source, 0, (CFDictionaryRef)thumbOpts);
		
		if (CGImageGetWidth(theCGImage))	// verify we got something
		{
			
			NSRect imageRect = NSZeroRect;
			imageRect.size.height = CGImageGetHeight(theCGImage);
			imageRect.size.width = CGImageGetWidth(theCGImage);
			
			NSImage* outImage = [[[NSImage alloc] initWithSize:imageRect.size] autorelease];
			[outImage setCachedSeparately:YES];

			[outImage lockFocus];
			CGContextRef imageContext = (CGContextRef)
				[[NSGraphicsContext currentContext] graphicsPort];
								
			CGContextDrawImage(imageContext, *(CGRect*)&imageRect, theCGImage);
						
			[outImage unlockFocus];
			
			[outImage setScalesWhenResized:YES];			
			
			CGImageRelease(theCGImage);
			CFRelease(source);
			
			return outImage;
		}
	}

	return nil;
}

@end
