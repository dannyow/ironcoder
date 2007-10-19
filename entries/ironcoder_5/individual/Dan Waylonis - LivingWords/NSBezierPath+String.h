//==============================================================================
// File:      NSBezierPath+String.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// Add a string/font to a path
//==============================================================================
#import <Cocoa/Cocoa.h>

@interface NSBezierPath(String)

- (void)appendString:(NSString *)string font:(NSFont *)font;

@end
