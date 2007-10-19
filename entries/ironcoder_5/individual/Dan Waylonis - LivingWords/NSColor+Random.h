//==============================================================================
// File:      NSColor+Random.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// Description
//==============================================================================
#import <Cocoa/Cocoa.h>

@interface NSColor(Random)
//==============================================================================
// Public
//==============================================================================
// Return a random RGBA color
+ (NSColor *)randomColor;

// Return a random RGB color with alpha = 1.0
+ (NSColor *)randomOpaqueColor;

@end
