/*
 *  CGHelpers.h
 *  WHYDFML
 *
 *  Created by Daniel Jalkut on 7/23/06.
 *  Copyright 2006 Red Sweater Software. All rights reserved.
 *
 */

#include <ApplicationServices/ApplicationServices.h>

// Colors
void CGContextSetRGBFillColorFrom255s(CGContextRef context, int red255, int green255, int blue255, int alpha255);
void CGContextSetRGBStrokeColorFrom255s(CGContextRef context, int red255, int green255, int blue255, int alpha255);

// Drawing
void CGContextFillRectInsetByDistance(CGContextRef context, CGRect theRect, float insetDistance);