//
//  MCAnimatedText.m
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/31/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "MCAnimatedText.h"


@implementation MCAnimatedText

- (id)init {

	self = [super init];
	if (self) {
		_attributes = [[NSMutableDictionary dictionary] retain];
		[_attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[_attributes setObject:[NSFont fontWithName:@"Helvetica-Bold" size:10.0] forKey:NSFontAttributeName];
	}
	return self;
}

- (void)dealloc {
	[_text release];
	[_attributes release];
	[super dealloc];
}


- (void)setSize:(float)size {

	NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:size];
	[_attributes setObject:font forKey:NSFontAttributeName];

}

- (void)setColor:(NSColor *)color {
	[_attributes setObject:color forKey:NSForegroundColorAttributeName];
}

- (void)setText:(NSString *)text {
	[_text release];
	_text = [text retain];
}

- (NSRect)bounds {
	NSSize size = [_text sizeWithAttributes:_attributes];
	return NSMakeRect(_location.x, _location.y, size.width, size.height);
}



- (void)draw {
	//get the context
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(context);
	
	CGContextSetAlpha(context, _opacity);
	[_text drawAtPoint:_location withAttributes:_attributes];
	
	CGContextRestoreGState(context);
}

@end
