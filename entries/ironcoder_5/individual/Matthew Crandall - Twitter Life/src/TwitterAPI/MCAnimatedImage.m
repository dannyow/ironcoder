//
//  MCAnimatedImage.m
//  TwitterAPI
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "MCAnimatedImage.h"


@implementation MCAnimatedImage

- (void)dealloc {
	[_image release];
	[super dealloc];
}

- (void)setImage:(NSImage *)image {
	[_image release];
	_image = [image retain];
	
	if (![_image isValid])
		NSLog(@"image is invalid.");
}

- (NSRect) bounds {
	if (_image)
		return NSMakeRect(_location.x, _location.y, [_image size].width, [_image size].height);
	
	return NSZeroRect;
}

- (void) draw {
	[_image compositeToPoint:_location operation:NSCompositeSourceOver fraction:_opacity];
}

@end
