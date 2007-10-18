//
//  ETCIImageAdditions.m
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import "ETCIImageAdditions.h"


@implementation CIImage(ETCIImageAdditions)


// after: http://gigliwood.com/weblog/Cocoa/Core_Image__Practic.html

- (NSImage *)toNSImageFromRect:(CGRect)rect {
	
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(rect.size.width, rect.size.height)] autorelease];

    [image addRepresentation:[NSCIImageRep imageRepWithCIImage:self]];
	
    return image;
}


- (NSImage *)toNSImage {
	
	return [self toNSImageFromRect:[self extent]];
}


@end
