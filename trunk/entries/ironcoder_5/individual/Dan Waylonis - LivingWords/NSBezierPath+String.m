//==============================================================================
// File:      NSBezierPath+String.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "NSBezierPath+String.h"

@implementation NSBezierPath(String)
//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================
- (void)appendString:(NSString *)string font:(NSFont *)font {
  NSTextStorage *ts = [[NSTextStorage alloc] initWithString:string attributes:
    [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
  NSLayoutManager *layout = [[NSLayoutManager alloc] init];
  
  [ts addLayoutManager:layout];

  int count = [ts length];
  NSRange glyphRange = NSMakeRange(0, count);
  NSGlyph *glyphs = (NSGlyph *)calloc(sizeof(NSGlyph), count + 1);
  NSRect *rects = (NSRect *)calloc(sizeof(NSRect), count + 1);

  [layout getGlyphs:glyphs range:glyphRange];
  
  // Calculate a sensible starting point, if none provided
  if ([self isEmpty]) {
    [font getBoundingRects:rects forGlyphs:glyphs count:count];
    
    float minx = (float)INT_MAX;
    float miny = (float)INT_MAX;
    float maxx = (float)-INT_MAX;
    float maxy = (float)-INT_MAX;
    NSRect textBounds = rects[0];
    
    for (int i = 0; i < count; ++i) {
      if (NSMinX(rects[i]) > maxx)
        maxx = NSMinX(rects[i]);
      
      if (NSMinX(rects[i]) < minx)
        minx = NSMinX(rects[i]);
      
      if (NSMinY(rects[i]) > maxy)
        maxy = NSMinY(rects[i]);
      
      if (NSMinY(rects[i]) < miny)
        miny = NSMinY(rects[i]);
      
      textBounds = NSUnionRect(textBounds, rects[i]);
    }
    
    [self moveToPoint:NSMakePoint(maxx - minx, maxy - miny + 2)];
  }
  
  [self appendBezierPathWithGlyphs:glyphs count:count inFont:font];
  free(glyphs);
  free(rects);
  [ts release];
  [layout release];
}

@end
