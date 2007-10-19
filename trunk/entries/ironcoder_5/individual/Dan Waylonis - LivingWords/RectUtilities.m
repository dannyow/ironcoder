//==============================================================================
// File:      RectUtilities.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "RectUtilities.h"
#import "Utilities.h"

//==============================================================================
#pragma mark -
#pragma mark || Functions ||
//==============================================================================
NSRect NormalizeRect(NSRect r) {
  if (NSWidth(r) < 0) {
    r.origin.x += r.size.width;
    r.size.width = -r.size.width;
  }
  
  if (NSHeight(r) < 0) {
    r.origin.y += r.size.height;
    r.size.height = -r.size.height;
  }
  
  return r;
}

//==============================================================================
NSRect RectWithPoints(NSPoint a, NSPoint b) {
  NSRect  r;
  
  r.origin = a;
  r.size.width = b.x - a.x;
  r.size.height = b.y - a.y;
  
  return NormalizeRect(r);
}

//==============================================================================
NSPoint RandomPointForSizeWithinRect(NSSize size, NSRect rect) {
	return NSMakePoint(floor(RandomFloatBetween(rect.origin.x,
                                              rect.origin.x + rect.size.width - size.width)),
                     floor(RandomFloatBetween(rect.origin.y,
                                              rect.origin.y + rect.size.height - size.height)));
}

//==============================================================================
NSRect CenteredRectInRect(NSRect innerRect, NSRect outerRect) {
	innerRect.origin.x = NSMinX(outerRect) + floor((NSWidth(outerRect) - NSWidth(innerRect)) / 2);
	innerRect.origin.y = NSMinY(outerRect) + floor((NSHeight(outerRect) - NSHeight(innerRect)) / 2);
	
	return innerRect;
}
