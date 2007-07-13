//
//  PTClockView.m
//  Relativity
//
//  Created by Philip on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PTClockView.h"


@implementation PTClockView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame]) == nil)
		return nil;

	clock = [[PTClock alloc] initDisplayingHours:YES minutes:YES seconds:YES tenths:YES];
	
    return self;
}

- (void)awakeFromNib
{
	[[self window] setContentSize:NSMakeSize(2*[clock size].width, 2*[clock size].height)];

	clockTimer = [[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(clockTick:) userInfo:NULL repeats:YES] retain];	
}

- (void)clockTick:(NSTimer *)myTimer
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect 
{
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(currentContext);

	[clock drawInContext:currentContext inRect:*(CGRect*)&rect];	

	CGContextRestoreGState(currentContext);
}

@end
