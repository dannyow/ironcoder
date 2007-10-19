//
//  MCAnimatedImage.h
//  TwitterAPI
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCAnimatedObject.h"

@interface MCAnimatedImage : MCAnimatedObject {
	NSImage *_image;
}

-(void)setImage:(NSImage *)image;

@end
