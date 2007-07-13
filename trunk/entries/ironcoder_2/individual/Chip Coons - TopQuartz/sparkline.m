//
//  sparkline.m
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//


#import "sparkline.h"


@implementation sparkline
- initWithRect:(CGRect*) rect  {
   
	self = [super init];
	
    w = rect->size.width;
    h = rect->size.height;
    
    x = rect->origin.x;
    y = rect->origin.y;
    
    increment = 10; 
	
    [self setName:@"newLine"];
	[self setDataArray:nil];
	
    return self;
}

- (void)dealloc;
{
	[self setName:nil];
	[self setDataArray:nil];
	[super dealloc];
}

- (NSString *)description;
{
	return ([[NSString stringWithFormat:@"<sparkline> = { name = %@ \n rect(%f, %f, %f %f) \n data = %@ \n}", name, x, y, w, h, [dataArray description]] autorelease]);
}



- (void)setDataArray:(NSArray *)inputArray;
{
	[dataArray release];
	if(inputArray == nil)
		return;
	
	dataArray = [[NSArray arrayWithArray:inputArray] retain];
}

- (NSArray *)dataArray;
{
	return [[dataArray retain] autorelease];
}

- (void)setName:(NSString *)aString;
{
	if(name == aString)
		return;
	[aString retain];
	[name release];
	name = aString;
}

- (NSString *)name;
{
	return [[name retain] autorelease];
}

- (void)showName:(CGContextRef) context frame:(CGRect*)contextRect bounds:(CGRect)boundsRect;
{
	float xDiff, yDiff;
	
	xDiff = boundsRect.origin.x - contextRect->origin.x;
	yDiff = boundsRect.origin.y - contextRect->origin.y;
	float heightForName = (boundsRect.size.height/3.0);
	
	if(heightForName > 12.0){
		heightForName = 12.0;
	}else if(heightForName < 8.0){
		heightForName = 8.0;
	}
	
	CGAffineTransform myTextTransform;
	CGContextSelectFont (context,
						 "Andale Mono",
						 10.0,
						 kCGEncodingMacRoman); 
	myTextTransform = CGAffineTransformMakeRotation(0);
	CGContextSetTextMatrix (context, myTextTransform);
	CGContextSetTextDrawingMode (context, kCGTextInvisible);		// so we can determin offset for right justified text
	CGContextSetTextPosition (context, 0, 0);
	CGPoint startingPoint = CGContextGetTextPosition (context);
	//NSLog(@"startingpoint = (%f, %f)", startingPoint.x, startingPoint.y);
	
	CGContextSetTextMatrix (context, myTextTransform);
	
	CGContextShowText (context, [[self name] cStringUsingEncoding:NSASCIIStringEncoding], [[self name] length]);
	
	CGPoint endingPoint = CGContextGetTextPosition (context);
	
	//NSLog(@"endingPoint = (%f, %f)", endingPoint.x, endingPoint.y);
	
	float widthOfName = (endingPoint.x - startingPoint.x);
	float indentForName = (boundsRect.size.width + boundsRect.origin.x) - (widthOfName);
	
	float heightOffset = ((boundsRect.size.height - heightForName) - ((boundsRect.size.height/10.0)*2.0))+yDiff;
	
	CGContextSetTextDrawingMode (context, kCGTextFillStroke);
	CGContextSetRGBFillColor (context, 1, 1, 1, 0.9);
	CGContextSetRGBStrokeColor (context, 1, 1, 1, 0.9);
	CGContextShowTextAtPoint (context, indentForName, heightOffset, [[self name] cStringUsingEncoding:NSASCIIStringEncoding], [[self name] length]);
	
	//NSLog(@" %@", [self name]);
	//NSLog(@" indent = %f, heightOffset = %f", indentForName, heightOffset);
	
}

- (void)drawSidebars:(CGContextRef) context frame:(CGRect*)contextRect bounds:(CGRect)boundingRect;
{
	float leftBarX, rightBarX, yy, width, height, xDiff, yDiff;
	
	xDiff =  boundingRect.origin.x - contextRect->origin.x;
	yDiff = boundingRect.origin.y - contextRect->origin.y;
	
	yy = yDiff;
	height = boundingRect.size.height;
	
	height = height + yDiff;
	width = boundingRect.size.width;
	leftBarX = 5.0;
	rightBarX = width - leftBarX;
	leftBarX = leftBarX + xDiff;
	rightBarX = rightBarX + xDiff;
	
	CGContextBeginPath (context);
	CGContextMoveToPoint (context, leftBarX, yy);
	CGContextAddLineToPoint (context, leftBarX, height);
	
	CGContextMoveToPoint (context, rightBarX, yy);
	CGContextAddLineToPoint (context, rightBarX, height);
	
	CGContextSetRGBStrokeColor (context, 0.1, 0.1, 0.1, 0.9);
	CGContextStrokePath (context);
}

- (void)drawSparkline:(CGContextRef) context frame:(CGRect*) contextRect bounds:(CGRect)boundsRect;
{
	float yy, xDiff, yDiff, midY, xSegment, xStart, xLoc, yLoc, yStart;
	
	xDiff =  boundsRect.origin.x - contextRect->origin.x;
	yDiff = boundsRect.origin.y - contextRect->origin.y;
	yy = boundsRect.size.height/100.0;
	midY = (boundsRect.size.height / 2.0) + yDiff;
	xSegment = (boundsRect.size.width - 10.0) / (float)[dataArray count];
	xStart = (boundsRect.origin.x + 5.1);
	yStart = ([[dataArray objectAtIndex:0] floatValue] * yy) + yDiff;
	
	xLoc = xStart;
	yLoc = yDiff;
	
	CGContextBeginPath (context);
	CGContextMoveToPoint (context, xLoc, yStart);
	
	NSEnumerator *e = [dataArray objectEnumerator];
	id anObject;
	
	while(anObject = [e nextObject]){
		xLoc = xLoc + xSegment;
		yLoc = ([anObject floatValue] * yy) + yDiff;
		CGContextAddLineToPoint (context, xLoc, yLoc);
	}
	CGContextSetRGBStrokeColor (context, 0.1, 0.1, 0.9, 1.0);
	CGContextStrokePath (context);
	
	
}


- (void)paint:(CGContextRef) context frame:(CGRect*) contextRect bounds:(CGRect*) boundsRect;
{
	CGRect textRect, graphRect;
	
	float xDiff = boundsRect->origin.x - contextRect->origin.x;
	float yDiff = boundsRect->origin.y - contextRect->origin.y;
	
	float widthSegment = (boundsRect->size.width / 4.0);
	float heightSegment = (boundsRect->size.height) - 4.0;
	float cx = contextRect->origin.x + xDiff;
	float cy = contextRect->origin.y + yDiff;
	
	textRect = CGRectMake( cx, cy+4.0, widthSegment, heightSegment);
	graphRect = CGRectMake( cx+widthSegment, cy+2.0, widthSegment*3.0, heightSegment);
	
	//NSLog(@"contextRect=(%f, %f, %f, %f)", contextRect->origin.x,  contextRect->origin.y,  contextRect->size.width,  contextRect->size.height);
	//NSLog(@"textRect=(%f, %f, %f, %f)", textRect.origin.x, textRect.origin.y, textRect.size.width, textRect.size.height);
	//NSLog(@"graphRect=(%f, %f, %f, %f)", graphRect.origin.x, graphRect.origin.y, graphRect.size.width, graphRect.size.height);
    
    CGContextSetRGBFillColor  (context, 1, 1, 0, 1);
    CGContextSetRGBStrokeColor(context, 1, 1, 0, 1);
    
	[self showName:context frame:contextRect bounds:textRect];
	[self drawSidebars:context frame:contextRect bounds:graphRect];
	[self drawSparkline:context frame:contextRect bounds:graphRect];
	
    CGContextRestoreGState(context);
	
}

@end
