/*
 *  CGHelpers.c
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/23/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include "CGHelpers.h"

// Colors
void CGContextSetRGBFillColorFrom255s(CGContextRef context, int red255, int green255, int blue255, int alpha255)
{
	CGContextSetRGBFillColor(context, red255 / 255.0, green255 / 255.0, blue255 / 255.0, alpha255 / 255.0);
}

void CGContextSetRGBStrokeColorFrom255s(CGContextRef context, int red255, int green255, int blue255, int alpha255)
{
	CGContextSetRGBStrokeColor(context, red255 / 255.0, green255 / 255.0, blue255 / 255.0, alpha255 / 255.0);
}

// Drawing

void CGContextFillRectInsetByDistance(CGContextRef context, CGRect theRect, float insetDistance)
{
	CGRect innerRect = CGRectInset(theRect, insetDistance, insetDistance);	
	CGContextFillRect(context, innerRect);
}