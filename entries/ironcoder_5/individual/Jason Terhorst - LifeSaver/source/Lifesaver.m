//
//  Lifesaver.m
//  LifeSaver
//
//  Created by Jason Terhorst on 3/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Lifesaver.h"


@implementation Lifesaver

- (float)xpos
{
	return xpos;
}

- (float)ypos
{
	return ypos;
}

- (float)zpos
{
	return zpos;
}

- (void)setXPos:(float)newPos
{
	xpos = newPos;
}

- (void)setYPos:(float)newPos
{
	ypos = newPos;
}

- (void)setZPos:(float)newPos
{
	zpos = newPos;
}


- (NSString *)color
{
	return color;
}

- (void)setColor:(NSString *)aColor
{
	color = [aColor retain];
	
	NSBundle *bundle;
	NSString *path;
	
	bundle = [NSBundle bundleForClass: [self class]];
	
	if ([color isEqualToString:@"green"])
		path = [bundle pathForResource: @"greenfull"  ofType: @"png"];
	else if ([color isEqualToString:@"purple"])
		path = [bundle pathForResource: @"purplefull"  ofType: @"png"];
	else
		path = [bundle pathForResource: @"redfull"  ofType: @"png"];
	
	
	image = [[NSImage alloc] initWithContentsOfFile: path];
}

- (BOOL)captured
{
	return captured;
}

- (void)setCaptured:(BOOL)key
{
	captured = key;
}


- (void)drawInView:(NSView *)aView
{
	
	// pseudo-3D drawing...
	float drawingYPosition = ypos + zpos;
	float drawingXPosition = xpos;
	
	NSRect drawRect;
	NSBezierPath * lifeSaver;
	
	drawRect = NSMakeRect(drawingXPosition, drawingYPosition, 91,75);
	//[[NSColor purpleColor] set];
	
	if ([color isEqualToString:@"green"])
		[[NSColor greenColor] set];
	else if ([color isEqualToString:@"purple"])
		[[NSColor purpleColor] set];
	else
		[[NSColor redColor] set];
	
	if (image) {
		NSRect imageRect = NSMakeRect(0,0,[image size].width,[image size].height);
		[image drawInRect:drawRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	} else {
		lifeSaver = [NSBezierPath bezierPathWithOvalInRect:drawRect];
		[lifeSaver setLineWidth:15];
		[lifeSaver stroke];
	}
	
}


@end
