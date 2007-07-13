/*
 *  GraphPatternDrawing.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/22/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "PlaidPatternDrawing.h"

#define H_PATTERN_SIZE 48
#define V_PATTERN_SIZE 48
 
static void MyDrawColoredPattern (void *info, CGContextRef myContext)
{
	CGRect targetRect = CGRectMake(0, 0, H_PATTERN_SIZE, V_PATTERN_SIZE);
	
	// Fill the background with white
	CGContextSetRGBFillColor(myContext, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(myContext, targetRect);
	
	CGContextSetLineWidth(myContext, 10.0);	
	
	// Make a grey cross
    CGContextSetRGBStrokeColor(myContext, 0.3, 0.3, 0.2, 0.4);	
	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, H_PATTERN_SIZE/2.0, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE/2.0, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);

	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, V_PATTERN_SIZE/2.0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE/2.0);
	CGContextStrokePath(myContext);

	// And frame the rect
	CGContextSetLineWidth(myContext, 5.0);	
	CGContextStrokeRect(myContext, targetRect);
	
	// Blues at 1/4 and 3/4 vertical
	CGContextSetLineWidth(myContext, 4.0);		
    CGContextSetRGBStrokeColor(myContext, 0.5, 0.8, 0.9, 0.2);	

	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, H_PATTERN_SIZE * .3, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE *.3, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);

	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, H_PATTERN_SIZE * 0.8, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE * 0.8, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);

	// Yellows at 1/4 and 3/4 vertical
	CGContextSetLineWidth(myContext, 4.0);		
    CGContextSetRGBStrokeColor(myContext, 1.0, 1.0, 0, 0.1);	

#if 0
	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, V_PATTERN_SIZE/4.0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE/4.0);
	CGContextStrokePath(myContext);
#endif

	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, V_PATTERN_SIZE * 0.75);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE  * 0.75);
	CGContextStrokePath(myContext);
}

void FillRectWithPlaidPattern(CGContextRef myContext, CGRect rect)
{
    CGPatternRef    pattern;// 1
    CGColorSpaceRef patternSpace;// 2
    float           alpha = 1.0;
	static const    CGPatternCallbacks callbacks = {0, // 5
                                        &MyDrawColoredPattern, 
                                        NULL};
 
    CGContextSaveGState (myContext);
    patternSpace = CGColorSpaceCreatePattern (NULL);// 6
    CGContextSetFillColorSpace (myContext, patternSpace);// 7
    CGColorSpaceRelease (patternSpace);// 8
 
    pattern = CGPatternCreate (NULL, // 9
                    CGRectMake (0, 0, H_PATTERN_SIZE, V_PATTERN_SIZE),// 10
                    CGAffineTransformMake (1, 0, 0, 1, 0, 0),// 11
                    H_PATTERN_SIZE, // 12
                    V_PATTERN_SIZE, // 13
                    kCGPatternTilingNoDistortion,// 14
                    true, // 15
                    &callbacks);// 16
 
    CGContextSetFillPattern (myContext, pattern, &alpha);// 17
    CGPatternRelease (pattern);// 18
    CGContextFillRect (myContext, rect);// 19
    CGContextRestoreGState (myContext);
}
