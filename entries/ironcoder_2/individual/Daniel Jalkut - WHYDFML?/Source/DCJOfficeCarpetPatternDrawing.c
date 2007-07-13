/*
 *  GraphPatternDrawing.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/22/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "DCJOfficeCarpetPatternDrawing.h"
#include "CGHelpers.h"

#define H_PATTERN_SIZE 128
#define V_PATTERN_SIZE 128

// Skanky macros for the colors of my rug
#define kReddishBrownHexValues 0x80, 0x40, 0x00, 0xFF
#define kLightBlueHexValues 0x81, 0xA1, 0xD2, 0xFF
#define kDarkBrownHexValues 0x46, 0x23, 0x00, 0xFF
#define kMustardGoldHexValues 0xCF, 0xBE, 0x4D, 0xFF
#define kLightBrownTanHexValues 0xBE, 0xB2, 0x9F, 0xFF
#define kDarkTanHexValues 0x81, 0x79, 0x6C, 0xFF
#define kLightBeigeHexValues 0xD4, 0xC6, 0xB0, 0xFF

#define BASEFILLCOLOR(colorCodes) \
					CGContextSetRGBFillColorFrom255s(myContext, colorCodes); \
					CGContextFillRect(myContext, myRect);

#define BIGSQUAREWITHCOLOR(colorCodes) \
					CGContextSetRGBFillColorFrom255s(myContext, colorCodes); \
					CGContextFillRectInsetByDistance(myContext, myRect, subSize / 3.5);

#define SMALLSQUAREWITHCOLOR(colorCodes) \
					CGContextSetRGBFillColorFrom255s(myContext, colorCodes); \
					CGContextFillRectInsetByDistance(myContext, myRect, subSize / 3.0);

#define FRAMEWITHCOLOR(colorCodes) \
					CGContextSetRGBStrokeColorFrom255s(myContext, colorCodes); \
					CGContextStrokeRectWithWidth(myContext, CGRectInset(myRect, subSize / 32.0, subSize / 32.0), subSize / 16.0);

static void MyDrawColoredPattern (void *info, CGContextRef myContext)
{
	CGRect targetRect = CGRectMake(0, 0, H_PATTERN_SIZE, V_PATTERN_SIZE);
	float subSize = V_PATTERN_SIZE / 4.0;
		
	// Fill the background with a light brown/tan
	CGContextSetRGBFillColorFrom255s(myContext, kLightBrownTanHexValues);
	CGContextFillRect(myContext, targetRect);

	// The carpet pattern is composed of 16 sub-patterns ... here we go!
	int xIter, yIter;
	for (xIter = 0; xIter < 4; xIter++)
	{
		for(yIter = 0; yIter < 4; yIter++)
		{
			CGRect myRect = {{xIter * subSize, yIter * subSize}, {subSize, subSize}};
				
			// We draw each of the 16 sub-patterns by hard-coding:
			
			// For debugging - trace the outline of every item
		//	CGContextStrokeRectWithWidth(myContext, myRect, 1.0);
			
			switch (yIter)
			{
				case 0:
				switch (xIter)
				{
					case 0:
					// First block is a brown outline with a brown square in the center
					SMALLSQUAREWITHCOLOR(kReddishBrownHexValues);
					FRAMEWITHCOLOR(kReddishBrownHexValues);
					break;

					case 1:
					// Brown rect with a blue square in the middle and dark tan frame
					BASEFILLCOLOR(kReddishBrownHexValues);
					SMALLSQUAREWITHCOLOR(kLightBlueHexValues);
					FRAMEWITHCOLOR(kDarkTanHexValues);
					break;
					
					case 2: 
					// Just a dark brown frame
					FRAMEWITHCOLOR(kDarkBrownHexValues);
					break;
					
					case 3:
					// Golden frame, lightblue fill, grey small rect
					BASEFILLCOLOR(kLightBlueHexValues);
					SMALLSQUAREWITHCOLOR(kLightBrownTanHexValues);
					FRAMEWITHCOLOR(kMustardGoldHexValues);
					break;										
				}
				break;
				case 1:
				switch (xIter)
				{
					case 0:
					// Blue fill, light beige frame and small box
					BASEFILLCOLOR(kLightBlueHexValues);
					BIGSQUAREWITHCOLOR(kLightBeigeHexValues);
					FRAMEWITHCOLOR(kLightBeigeHexValues);
					break;

					case 1:
					// Blue frame, brown fill
					BASEFILLCOLOR(kReddishBrownHexValues);
					FRAMEWITHCOLOR(kLightBlueHexValues);
					break;
					
					case 2: 
					// Brown fill, dark brown square
					BASEFILLCOLOR(kReddishBrownHexValues);
					BIGSQUAREWITHCOLOR(kDarkBrownHexValues);	
					FRAMEWITHCOLOR(kLightBrownTanHexValues);									
					break;
					
					case 3:
					// Golden frame, dark tan fill
					BASEFILLCOLOR(kDarkTanHexValues);
					FRAMEWITHCOLOR(kMustardGoldHexValues);
					break;										
				}
				break;				
				case 2:
				switch (xIter)
				{
					case 0:
					// Blue frame with a brown square
					SMALLSQUAREWITHCOLOR(kReddishBrownHexValues);
					FRAMEWITHCOLOR(kLightBlueHexValues);
					break;

					case 1:
					// Dark tan frame & fill with large beige box
					BASEFILLCOLOR(kDarkTanHexValues);
					BIGSQUAREWITHCOLOR(kLightBeigeHexValues);
					FRAMEWITHCOLOR(kDarkTanHexValues);
					break;
					
					case 2: 
					// Just a just a light beige frame
					FRAMEWITHCOLOR(kLightBeigeHexValues);
					break;
					
					case 3:
					// Base frame, gold fill, beige box
					BASEFILLCOLOR(kMustardGoldHexValues);
					BIGSQUAREWITHCOLOR(kLightBeigeHexValues);
					FRAMEWITHCOLOR(kLightBrownTanHexValues);
					break;										
				}
				break;
				case 3:
				switch (xIter)
				{
					case 0:
					// Base frame, brown fill, dark tan small square
					BASEFILLCOLOR(kReddishBrownHexValues);					
					SMALLSQUAREWITHCOLOR(kDarkTanHexValues);
					FRAMEWITHCOLOR(kLightBrownTanHexValues);
					break;

					case 1:
					// Light beige frame, blue fill, gold square
					BASEFILLCOLOR(kLightBlueHexValues);
					SMALLSQUAREWITHCOLOR(kMustardGoldHexValues);
					FRAMEWITHCOLOR(kLightBeigeHexValues);
					break;
					
					case 2: 
					// Dark tan frame, base fill, brown large square
					BIGSQUAREWITHCOLOR(kReddishBrownHexValues);
					FRAMEWITHCOLOR(kDarkTanHexValues);
					break;
					
					case 3:
					// Brown fill with dark brown frame
					BASEFILLCOLOR(kReddishBrownHexValues);
					FRAMEWITHCOLOR(kDarkBrownHexValues);
					break;										
				}
				break;				
			}
		}
	}	

#if 0		
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

	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, V_PATTERN_SIZE/4.0);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE/4.0);
	CGContextStrokePath(myContext);

	CGContextBeginPath(myContext);
    CGContextMoveToPoint(myContext, 0, V_PATTERN_SIZE * 0.75);
    CGContextAddLineToPoint(myContext, H_PATTERN_SIZE, V_PATTERN_SIZE  * 0.75);
	CGContextStrokePath(myContext);
#endif

}

void FillRectWithDCJOfficeCarpetPattern(CGContextRef myContext, CGRect rect)
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
