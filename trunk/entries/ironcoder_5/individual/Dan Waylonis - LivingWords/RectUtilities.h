//==============================================================================
// File:      RectUtilities.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// NSRect utilities
//==============================================================================
#import <Cocoa/Cocoa.h>

//==============================================================================
// Public
//==============================================================================
NSRect NormalizeRect(NSRect r);
NSRect RectWithPoints(NSPoint a, NSPoint b);
NSPoint RandomPointForSizeWithinRect(NSSize size, NSRect rect);
NSRect CenteredRectInRect(NSRect innerRect, NSRect outerRect);
