/*
 *  GraphPatternDrawing.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/22/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "DenimPatternDrawing.h"

#define H_PATTERN_SIZE 5
#define V_PATTERN_SIZE 4
 
static void MyDrawColoredPattern (void *info, CGContextRef myContext)
{	
	// Target 
	CGRect targetRect = CGRectMake(0, 0, H_PATTERN_SIZE,V_PATTERN_SIZE);
	
	// Light blue fill in background
	CGContextSetRGBFillColor(myContext, 0.0, 0.0, 0.3, 1.0);
	CGContextFillRect(myContext, targetRect);
	
	// Dark blue diagonal stroke
    CGContextSetRGBStrokeColor(myContext, .10, .10, .30, 1.0);
	CGContextBeginPath(myContext);
	CGContextSetLineWidth(myContext, 1.5);
    CGContextMoveToPoint(myContext, 0, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);

	// Stroke a thin white line
    CGContextSetRGBStrokeColor(myContext, 1, 1, 1, 0.8);	
	CGContextSetLineWidth(myContext, .5);
	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);	

#if 0
	// and a vertical
    CGContextSetRGBStrokeColor(myContext, .8, .8, 1, 0.8);	
	CGContextSetRGBFillColor(myContext, .18, .18, .30, 1.0);		
	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, H_PATTERN_SIZE/2.0, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE/2.0, V_PATTERN_SIZE);
    CGContextMoveToPoint(myContext, H_PATTERN_SIZE * 0.45, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE *0.25, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);	
#endif	
}

void FillRectWithDenimPattern(CGContextRef myContext, CGRect rect)
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
                    kCGPatternTilingConstantSpacing,// 14
                    true, // 15
                    &callbacks);// 16
 
    CGContextSetFillPattern (myContext, pattern, &alpha);// 17
    CGPatternRelease (pattern);// 18
    CGContextFillRect (myContext, rect);// 19
    CGContextRestoreGState (myContext);
}
