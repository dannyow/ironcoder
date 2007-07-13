//
//  TopView.m
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import "TopView.h"


@implementation TopView


- (id)initWithRect:(CGRect*) rect;
{
	if(![super init])
		return nil;
	
	x = rect->origin.x;
	y = rect->origin.y;
	w = rect->size.width;
	h = rect->size.height;
	
	displayItems = [[NSMutableArray arrayWithCapacity:5] retain];
	
	aSpark = [[[sparkline alloc] initWithRect:rect] retain];
	[aSpark setName:@"Test Line"];
	[aSpark setDataArray:[NSArray arrayWithObjects: [NSNumber numberWithFloat:0.4],
		[NSNumber numberWithFloat:1.3],
		[NSNumber numberWithFloat:10.2],
		[NSNumber numberWithFloat:21.7],
		[NSNumber numberWithFloat:21.7],
		[NSNumber numberWithFloat:14.6],
		[NSNumber numberWithFloat:4.5],
		[NSNumber numberWithFloat:2.1],
		[NSNumber numberWithFloat:0.0],
		nil]];
	
	[displayItems addObject:aSpark];
	
	return self;
}

- (void)dealloc;
{
	[displayItems release];
	[aSpark release];
	[super dealloc];
}

- (void) clear: (CGContextRef) context  withRect:(CGRect*) contextRect {
    // make a semiTransparent background.
    CGContextSetRGBFillColor(context, 0.3, 0.3, 0.3, 0.6);  
    
    //CGContextSetRGBFillColor(context, backgroundR, backgroundG, backgroundB, 1.0);  
    CGContextFillRect(context,*contextRect);
}

- (void) displayTitle:(CGContextRef) context withRect:(CGRect*) contextRect;
{
	float xLoc, yLoc;
	NSString *title = [[NSString stringWithString:@"TopQuartz"] retain];
	
	xLoc = contextRect->origin.x + 5.0;
	yLoc =  (contextRect->origin.y + contextRect->size.height) - 20.0;
	
	CGAffineTransform myTextTransform;
	CGContextSelectFont (context,
						 "Andale Mono",
						 10.0,
						 kCGEncodingMacRoman); 
	myTextTransform = CGAffineTransformMakeRotation(0);
	CGContextSetTextMatrix (context, myTextTransform);
	CGContextSetTextDrawingMode (context, kCGTextInvisible);		// so we can determin offset for right justified text
	CGContextSetTextPosition (context, 0, 0);
	CGContextSetTextMatrix (context, myTextTransform);
	
	CGContextSetTextDrawingMode (context, kCGTextFillStroke);
	CGContextSetRGBFillColor (context, 0, 1, 0, 0.85);
	CGContextSetRGBStrokeColor (context, 0, 1, 0, 0.85);
	CGContextShowTextAtPoint (context, xLoc, yLoc, [title cStringUsingEncoding:NSASCIIStringEncoding], [title length]);
	[title release];
}

- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) rect {
    [self clear:context withRect:rect];
	[self displayTitle:context withRect:rect];
	CGRect bounds;
	float nX, nY, nW, nH;
	nW = rect->size.width;
	nH = rect->size.height/6.0;
	nX = rect->origin.x;
	nY = ((rect->origin.y + rect->size.height))- (nH/2.0);
	
	NSEnumerator *e = [displayItems objectEnumerator];
	sparkline *anySpark;
	
	while(anySpark = [e nextObject]){
		//adjust vertical bounds
		nY = nY - nH;
		bounds = CGRectMake(nX, nY, nW, nH);
		[anySpark paint:context frame:rect bounds:&bounds];
		
	}
	
	

}


- (NSMutableArray *)displayItems;
{
	return [[[NSMutableArray arrayWithArray:displayItems] retain] autorelease];
}

- (void)setDisplayItems:(NSArray *)inputArray;
{
	maxData=0;
	sparkline *anySpark;
	NSMutableArray *tArray;
	
	// take the first 5 entries from inputArray and copy them into diaplayItems
	int i=0;
	int final = [inputArray count]-1;
	if(final > 5){
		final = 5;
	}
	
	//NSLog(@"inputArray = %@", [inputArray description]);
	NSEnumerator *e = [displayItems objectEnumerator];
	while(anySpark = [e nextObject]){
		[anySpark setDataArray:[[inputArray objectAtIndex:i] objectForKey:@"cpuArray"]];
		[anySpark setName:[[inputArray objectAtIndex:i] objectForKey:@"process"]];	
		if([[anySpark dataArray] count] >= maxData){
			maxData = [[anySpark dataArray] count];
		}else{
			tArray = [[NSMutableArray arrayWithArray:[[inputArray objectAtIndex:i] objectForKey:@"cpuArray"]] retain];
			[tArray addObject:[NSNumber numberWithFloat:0.0]];
			[anySpark setDataArray:tArray];
		}
		i++;
	}
	
	while(i < final){
		CGRect aRect = CGRectMake(x, y, w, h);
		sparkline *newSpark = [[[sparkline alloc] initWithRect:&aRect] retain];
		[newSpark setDataArray:[[inputArray objectAtIndex:i] objectForKey:@"cpuArray"]];
		[newSpark setName:[[inputArray objectAtIndex:i] objectForKey:@"process"]];
		[displayItems addObject:newSpark];
		if([[newSpark dataArray] count] > maxData){
			maxData = [[newSpark dataArray] count];
		}else{
			tArray = [[NSMutableArray arrayWithArray:[[inputArray objectAtIndex:i] objectForKey:@"cpuArray"]] retain];
			[tArray addObject:[NSNumber numberWithFloat:0.0]];
			[anySpark setDataArray:tArray];
		}
		[newSpark release];
		i++;
	}
	
	//pad entries to age them out
}


@end
