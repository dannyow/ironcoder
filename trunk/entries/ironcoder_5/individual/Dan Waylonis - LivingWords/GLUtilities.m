//==============================================================================
// File:      GLUtilities.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import <OpenGL/gl.h>

#import "GLUtilities.h"

#define glVertex2fOffset(x, y, o) glVertex2f(x + o, y + o)

//==============================================================================
#pragma mark -
#pragma mark || Functions ||
//==============================================================================
void DrawGLRect(NSRect rect, NSColor *color) {
	NSColor	*rgbColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	float		c[4];
	float offset = 0.5;
  
	[rgbColor getComponents:c];
	glColor4fv(c);
	glBegin(GL_LINE_LOOP);
	glVertex2fOffset(NSMinX(rect), NSMinY(rect), offset);
	glVertex2fOffset(NSMaxX(rect) - 1, NSMinY(rect), offset);
	glVertex2fOffset(NSMaxX(rect) - 1, NSMaxY(rect) - 1, offset);
	glVertex2fOffset(NSMinX(rect), NSMaxY(rect) - 1, offset);
	glEnd();
}
