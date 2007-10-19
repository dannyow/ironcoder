//
//  LifeCityView.m
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import "LifeCityView.h"


@implementation LifeCityView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
	//NSLog(NSStringFromRect(frame));
	//GLDebug(@"initWithFrame:");
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		NSRect newFrame = frame;
		newFrame.origin.x = 0;
		newFrame.origin.y = 0;
		openGLView = [[LifeCityOpenGLView alloc] initWithFrame:newFrame];
		if( openGLView ) { 
			[openGLView initOpenGL];
			[self setAutoresizesSubviews:YES];
			[self addSubview:openGLView];
			[self setAnimationTimeInterval:1.0/60.0];
		}
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
	[GLDebug writeToFile];
}

- (void)drawRect:(NSRect)rect
{
	[openGLView drawRect:rect];
   // [super drawRect:rect];
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
