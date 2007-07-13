//
//  PTPlanetView.m
//  Relativity
//
//  Created by Philip on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PTPlanetView.h"


@implementation PTPlanetView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame]) == nil)
		return nil;

	clock = [[PTClock alloc] initDisplayingHours:YES minutes:YES seconds:YES tenths:YES];
	
	clockSize = [clock size];
	clockSize.width = clockSize.width*2;
	clockSize.height = clockSize.height*2;
	
	//load earth.png into image
	NSData *imageDataSource = [[NSImage imageNamed:@"earth"] TIFFRepresentation];
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageDataSource, NULL);
	image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
	
	return self;
}

- (void)awakeFromNib
{
	clockTimer = [[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(clockTick:) userInfo:NULL repeats:YES] retain];	
	
	drawingRect = CGRectMake([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, [self bounds].size.height);
}

- (void)clockTick:(NSTimer *)myTimer
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect 
{
	CGContextRef currentContext = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(currentContext);
	
	CGContextDrawImage(currentContext, drawingRect, image);
	
	CGContextTranslateCTM(currentContext, [self bounds].size.width/2, [self bounds].size.height/2);
	CGRect clockRect = CGRectMake(-clockSize.width/2, -clockSize.height/2, clockSize.width, clockSize.height);
	[clock drawInContext:currentContext inRect:clockRect];	
	
	CGContextRestoreGState(currentContext);	
}

@end
