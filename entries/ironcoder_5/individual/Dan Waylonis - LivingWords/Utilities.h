//==============================================================================
// File:      Utilities.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// General utilities
//==============================================================================
#import <Cocoa/Cocoa.h>

//==============================================================================
// Inlines
//==============================================================================
static inline int RandomIntBetween(int a, int b) {
	int range = b - a < 0 ? b - a - 1 : b - a + 1; 
	int value = (int)(range * ((float)random() / (float) LONG_MAX));
	
	return(value == range ? a : a + value);
}

//==============================================================================
static inline float RandomFloatBetween(float a, float b) {
	return a + (b - a) * ((float)random() / (float) LONG_MAX);
}
