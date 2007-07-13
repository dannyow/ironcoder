/*
 *  GraphPatternDrawing.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/22/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "LinenPatternDrawing.h"

#define H_PATTERN_SIZE 4
#define V_PATTERN_SIZE 4
 
static void MyDrawColoredPattern (void *info, CGContextRef myContext)
{
	// Take the color specified and use it
	CGColorRef patternColor = (CGColorRef) info;
	CGContextSetStrokeColorWithColor(myContext, patternColor);
	
	// Stroke a line from the lower-left corner to the upper right
	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, 0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE);
	CGContextStrokePath(myContext);
}

void FillRectWithLinenPattern(CGContextRef myContext, CGRect rect, CGColorRef patternColor)
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
 
    pattern = CGPatternCreate (patternColor, // 9
                    CGRectMake (0, 0, H_PATTERN_SIZE, V_PATTERN_SIZE),// 10
                    CGAffineTransformMake (1, 0, 0, 1, 0, 0),// 11
                    H_PATTERN_SIZE, // 12
                    V_PATTERN_SIZE, // 13
                    kCGPatternTilingConstantSpacingMinimalDistortion,// 14
                    true, // 15
                    &callbacks);// 16
 
    CGContextSetFillPattern (myContext, pattern, &alpha);// 17
    CGPatternRelease (pattern);// 18
    CGContextFillRect (myContext, rect);// 19
    CGContextRestoreGState (myContext);
}
