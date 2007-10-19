//
//  PixureTestView.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PixureTestView.h"
#import "PixureTestController.h"
#import "PixureSystem.h"
#import "NSImage_CenteredDrawingAdditions.h"


@implementation PixureTestView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark -
#pragma mark Accessors

- (PixureTestController*)controller;
{ 
	return [[controller retain] autorelease]; 
}


- (void)setController:(PixureTestController*)inController;
{
	if ([[self controller] isEqualTo:inController])
		return;

	[inController retain];
	[controller release];
	controller = inController;
}




#pragma mark -
#pragma mark Drawing


- (void)drawRect:(NSRect)rect 
{
//	if (nil != [[self controller] system])
//		NSRectFill([self bounds]);

	[[[[self controller] system] generatedImage] drawCenteredinRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
}




@end
