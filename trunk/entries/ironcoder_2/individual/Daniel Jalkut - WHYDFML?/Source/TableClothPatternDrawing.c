/*
 *  GraphPatternDrawing.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/22/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "TableClothPatternDrawing.h"

#define H_PATTERN_SIZE 24
#define V_PATTERN_SIZE 24
 
static void MyDrawColoredPattern (void *info, CGContextRef myContext)
{
	float h_subunit = H_PATTERN_SIZE / 2.0;
	float v_subunit = V_PATTERN_SIZE / 2.0;
	CGRect  myRect1 = {{0,0}, {h_subunit, v_subunit}},
            myRect2 = {{h_subunit, v_subunit}, {h_subunit, v_subunit}},
            myRect3 = {{0,v_subunit}, {h_subunit, v_subunit}},
            myRect4 = {{h_subunit,0}, {h_subunit, v_subunit}};
 
	// Draw a yellow square
	CGContextSetRGBFillColor(myContext, 1, 1, 0, 0.8);
	CGContextFillRect(myContext, myRect3);
	
	// Draw two orange squres
	CGContextSetRGBFillColor(myContext, 1, 0.5, 0, 0.8);
	CGContextFillRect(myContext, myRect2);
	CGContextFillRect(myContext, myRect1);
	
	// And a red square
	CGContextSetRGBFillColor(myContext, 1, 0, 0, 0.8);
	CGContextFillRect(myContext, myRect4);	

#if 0
	// A little stitching?
	float stitchOffset = 2.0;
    CGContextSetRGBStrokeColor(myContext, 1, 1, 1, 1);	
	CGContextSetLineWidth(myContext, 1);
	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, v_subunit-stitchOffset);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, v_subunit-stitchOffset);
	CGContextClosePath(myContext);
	CGContextStrokePath(myContext);	
#endif
}

void FillRectWithTableClothPattern(CGContextRef myContext, CGRect rect)
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
