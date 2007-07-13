//
//  UnicornView.m
//  DaliClock
//
//  Created by Kevin Ballard on 7/23/06.
//  Copyright 2006 Tildesoft. All rights reserved.
//

#import "UnicornView.h"


@implementation UnicornView

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
	NSRectFill(rect);
	
	NSImage *unicorn = [NSImage imageNamed:@"unicorn.png"];
	NSRect sourceRect = { NSZeroPoint, [unicorn size] };
	[unicorn drawInRect:[self bounds] fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
