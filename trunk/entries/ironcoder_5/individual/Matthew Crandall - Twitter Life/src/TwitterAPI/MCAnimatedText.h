//
//  MCAnimatedText.h
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/31/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCAnimatedObject.h"


@interface MCAnimatedText : MCAnimatedObject {
	NSString *_text;
	NSMutableDictionary *_attributes;
}

- (void)draw;
- (NSRect)bounds;

- (void)setSize:(float)size;
- (void)setColor:(NSColor *)color;
- (void)setText:(NSString *)text;

@end
