//
//  TopQuartzView.m
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import "TopQuartzView.h"


@implementation TopQuartzView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		tv = [[TopView alloc]initWithRect:(CGRect*)&frame];
    }
    return self;
}

- (void)dealloc;
{
	[tv release];
	[super dealloc];
}


- (void)updateData:(NSArray *)anArray;
{
	[tv setDisplayItems:anArray];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	NSGraphicsContext *nsgc = [NSGraphicsContext currentContext];
    CGContextRef gc = [nsgc graphicsPort];
    
    // comment out these two lines for a transparent background.    
    //[[NSColor blackColor] set];
    //NSRectFill(NSMakeRect(0,0,[self frame].size.width, [self frame].size.height));
    
    [tv drawInContext:gc withRect:(CGRect*)&rect];
}

@end
