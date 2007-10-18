//
//  SpaceView.m
//  SpaceViewer
//
//  Created by Students on 10/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SpaceView.h"


@implementation SpaceView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        images = [[NSMutableArray array] init];
		[images addObject:[NSImage imageNamed:@"sun.png"]];
		[images addObject:[NSImage imageNamed:@"mercury.png"]];
		[images addObject:[NSImage imageNamed:@"venus.png"]];
		[images addObject:[NSImage imageNamed:@"earth.png"]];
		[images addObject:[NSImage imageNamed:@"mars.png"]];
		[images addObject:[NSImage imageNamed:@"jupiter.png"]];
		[images addObject:[NSImage imageNamed:@"saturn.png"]];
		[images addObject:[NSImage imageNamed:@"uranus.png"]];
		[images addObject:[NSImage imageNamed:@"neptune.png"]];
		[images addObject:[NSImage imageNamed:@"pluto.png"]];
		
		int fullwidth = [self bounds].size.width;
		int halfwidth = fullwidth/2;
		int imagesize = [self bounds].size.height - 40;
		
		planetsImage = [[NSImage alloc] initWithSize:NSMakeSize([self bounds].size.width*10, [self bounds].size.height)];
		NSSize imageSize = NSMakeSize([self bounds].size.width*10, [self bounds].size.height);
		NSRect imageRect = NSMakeRect(0,0,imageSize.width,imageSize.height);
		
		[planetsImage lockFocus];
		int x, count = [images count];
		int drawingpoint = 0;
		for (x=0;x<count;x++) {
			[[images objectAtIndex:x] drawInRect:NSMakeRect(drawingpoint, 40, imagesize, imagesize) fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
			drawingpoint = drawingpoint + fullwidth;
		}
		
		NSBitmapImageRep * bitmapimagerep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:imageRect];
		
		[planetsImage unlockFocus];
		
		ciPlanets = [[CIImage alloc] initWithBitmapImageRep:bitmapimagerep];
		filter = [[CIFilter filterWithName: @"CIMotionBlur"
                       keysAndValues: 
                       @"inputImage", ciPlanets, 
                       @"inputRadius", [NSNumber numberWithFloat: 10.0],
                       @"inputAngle", [NSNumber numberWithFloat:0.0],
                       nil] retain];
		
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [[NSBezierPath bezierPathWithRect:rect] fill];
	
	int width = rect.size.width;
	int fullwidth = width * 10;
	int height = rect.size.height;
	int halfwaypoint = width / 2;
	
	int roundedvalue = currentPosition;
	int zeropoint = 0.0 - (width * currentPosition) + (halfwaypoint/2);
	
	//[planetsImage drawInRect:NSMakeRect(zeropoint,0,fullwidth,height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	CGRect pictureRect = CGRectMake(zeropoint, 0, fullwidth, height);
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	if (currentPosition != roundedvalue) {
	[context drawImage: [filter valueForKey: @"outputImage"]
                     inRect: pictureRect
                     fromRect: CGRectMake(0, 0, fullwidth, height)];
	} else {
		[planetsImage drawInRect:NSMakeRect(zeropoint,0,fullwidth,height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		[delegate finishedScrollingAndLandedOn:roundedvalue];
	}
	
	int markerPosition = (currentPosition - roundedvalue) * width;
	if (markerPosition < 0.5) {
		markerPosition = markerPosition + halfwaypoint;
	}
	
	[[NSColor grayColor] set];
	NSRect markerRect = NSMakeRect(markerPosition,40,5,50);
	//[[NSBezierPath bezierPathWithRect:markerRect] fill];
}

- (void)setNextPosition:(double)newPos
{
	nextPosition = newPos;
	
	if (!scrollTimer) {
		scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(repositionView:) userInfo:nil repeats:YES];
		[scrollTimer fire];
	}
}

- (void)repositionView:(NSTimer *)timer
{
	if (currentPosition != nextPosition) {
		if (currentPosition > nextPosition) {
			if (currentPosition - nextPosition < 1)
				currentPosition = nextPosition;
			else
				currentPosition = currentPosition - 0.5;
		} else {
			if (nextPosition - currentPosition < 1)
				currentPosition = nextPosition;
			else
				currentPosition = currentPosition + 0.5;
		}
	} else {
		[timer invalidate];
		scrollTimer = nil;
	}
	NSLog(@"currentPosition: %f", currentPosition);
	[self setNeedsDisplay:YES];
}

@end
