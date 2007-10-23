/**********************************************************************

Created by Rocco Bowling and Jonathan Saggau
Big Nerd Ranch, Inc
OpenGL Bootcamp

Copyright 2006 Rocco Bowling and Jonathan Saggau, All rights reserved.

/***************************** License ********************************

This code can be freely used as long as these conditions are met:

1. This header, in its entirety, is kept with the code
3. It is not resold, in it's current form or in modified, as a
teaching utility or as part of a teaching utility

This code is presented as is. The author of the code takes no
responsibilities for any version of this code.

(c) 2006 Rocco Bowling and Jonathan Saggau

*********************************************************************/

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>

extern NSRect NSRectInsideRect(NSRect a, NSRect b);

@interface NSImage (NSImageOpenGLAdditions)

-(GLuint) texture;
-(GLuint) texture:(int)mode;
-(GLuint) texture:(int)mode
	  compression:(int)compression;
- (NSRect) bounds;

+ (NSImage *) loadImage:(NSString *)image_name;
+ (NSImage *) loadImage:(NSString *)image_name
		   restrictSize:(NSSize) size;

- (void)drawAtPoint:(NSPoint)point
		  withScale:(NSSize)scale
		  operation:(NSCompositingOperation)op
		   fraction:(float)delta;

- (void)drawAtPoint:(NSPoint)point
		   withSize:(NSSize)scale
		  operation:(NSCompositingOperation)op
		   fraction:(float)delta;

@end


