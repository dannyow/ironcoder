//
//  NSImage_Extensions.m
//  FallingSand
//
//  Created by Jonathan Wight on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSImage_Extensions.h"


@implementation NSImage (NSImage_Extensions)

+ (NSImage *)imageFromCGImageRef:(CGImageRef)inCGImage
{
NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
CGContextRef imageContext = nil;
NSImage* newImage = nil;

// Get the image dimensions.
imageRect.size.height = CGImageGetHeight(inCGImage);
imageRect.size.width = CGImageGetWidth(inCGImage);

// Create a new image to receive the Quartz image data.
newImage = [[NSImage alloc] initWithSize:imageRect.size]; 
[newImage lockFocus];

// Get the Quartz context and draw.
imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
CGContextDrawImage(imageContext, *(CGRect*)&imageRect, inCGImage);
[newImage unlockFocus];

return newImage;
}

@end
