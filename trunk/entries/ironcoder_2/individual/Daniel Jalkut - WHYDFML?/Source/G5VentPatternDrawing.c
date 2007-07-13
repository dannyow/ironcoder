/*
 *  GraphPatternDrawing.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/22/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "G5VentPatternDrawing.h"

#define H_PATTERN_SIZE 10
#define V_PATTERN_SIZE 10
 
static void MyDrawColoredPattern (void *info, CGContextRef myContext)
{
	static const float insetAmount = H_PATTERN_SIZE / 3.0;
	CGRect targetRect = CGRectMake(insetAmount, insetAmount, H_PATTERN_SIZE - insetAmount, V_PATTERN_SIZE - insetAmount);

	// Just a dark semi-transparent black circle
	CGContextSetRGBFillColor(myContext, 0, 0, 0, 0.7);
	CGContextFillEllipseInRect(myContext, targetRect);
//	CGContextSetLineWidth(myContext,.5);
//	CGContextSetRGBStrokeColor(myContext, 1, 1, 1, 0.2);
//	CGContextStrokeEllipseInRect(myContext, targetRect);
}

void FillRectWithG5VentPattern(CGContextRef myContext, CGRect rect)
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
