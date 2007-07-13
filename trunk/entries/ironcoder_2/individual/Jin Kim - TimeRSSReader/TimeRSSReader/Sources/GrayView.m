//
//  GrayView.m
//  TimeRSSReader
//
//  Created by Jin Kim on 7/23/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "GrayView.h"


@implementation GrayView

- (void)drawRect:(NSRect)rect
{
	[[NSColor colorWithCalibratedWhite:0.95 alpha:1] set];
	NSRectFill(rect);
}

@end