//
//  BZRedButton.m
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-22.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import "BZRedButton.h"


@implementation BZRedButton

- (void)dealloc {
	[redVersion release];

	[super dealloc];
}

#pragma mark Accessors

- (void)setTitle:(NSString *)newTitle {
	[redVersion release];
	redVersion = nil;

	[super setTitle:newTitle];
}

- (void)setFrame:(NSRect)newFrame {
	[redVersion release];
	redVersion = nil;
	
	[super setFrame:newFrame];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)rect {
//	[super drawRect:rect];

	NSRect imageRect = [self bounds];

	if(!redVersion) {
		NSString *tmp = NSTemporaryDirectory();
		//Plain button on clear background.
		NSImage *selfImage = [[NSImage alloc] initWithSize:imageRect.size];
		[selfImage setFlipped:YES];
		[selfImage lockFocus];
		[[NSColor clearColor] setFill];
		NSRectFill(imageRect);
		[super drawRect:imageRect];
		[selfImage unlockFocus];
		[[selfImage TIFFRepresentation] writeToFile:[tmp stringByAppendingPathComponent:@"kill-origonclear.tiff"] atomically:NO];

		//Red button on red background.
		NSImage *selfImageRed = [selfImage copy];
		[selfImageRed lockFocus];
		[[NSColor redColor] setFill];
		NSRectFillUsingOperation(imageRect, NSCompositePlusDarker);
		[selfImageRed unlockFocus];
		[[selfImageRed TIFFRepresentation] writeToFile:[tmp stringByAppendingPathComponent:@"kill-redonred.tiff"] atomically:NO];

		redVersion = [selfImageRed copy];
		[redVersion lockFocus];
		//Clear button on red background.
		[selfImage drawAtPoint:NSZeroPoint
					  fromRect:imageRect
					 operation:NSCompositeXOR
						 fraction:1.0f];
		//Red button on clear background. (This is it!)
		[selfImageRed drawAtPoint:NSZeroPoint
						 fromRect:imageRect
						operation:NSCompositeXOR
						 fraction:1.0f];
		[redVersion unlockFocus];
		[[redVersion TIFFRepresentation] writeToFile:[tmp stringByAppendingPathComponent:@"kill-redonclear.tiff"] atomically:NO];

		[selfImage release];
		[selfImageRed release];
	}

	[redVersion drawAtPoint:NSZeroPoint
				   fromRect:imageRect
				  operation:NSCompositeSourceOver
				   fraction:1.0f];
}

@end
