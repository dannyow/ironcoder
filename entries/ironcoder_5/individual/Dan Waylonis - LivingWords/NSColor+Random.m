//==============================================================================
// File:      NSColor+Random.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "NSColor+Random.h"

static inline float RandomComponent() {
  return (float)random() / (float)LONG_MAX;
}

@implementation NSColor(Random)
//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================
+ (NSColor *)randomColor {
  float c[4];
  
  c[0] = RandomComponent();
  c[1] = RandomComponent();
  c[2] = RandomComponent();
  c[3] = RandomComponent();
  
  return [NSColor colorWithCalibratedRed:c[0] green:c[1] blue:c[2] alpha:c[3]];
}

//==============================================================================
+ (NSColor *)randomOpaqueColor {
  float c[3];
  
  c[0] = RandomComponent();
  c[1] = RandomComponent();
  c[2] = RandomComponent();
  
  return [NSColor colorWithCalibratedRed:c[0] green:c[1] blue:c[2] alpha:1.0];
}

@end
