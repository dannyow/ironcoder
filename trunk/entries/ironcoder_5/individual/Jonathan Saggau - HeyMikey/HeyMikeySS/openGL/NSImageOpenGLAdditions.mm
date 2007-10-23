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

#import "NSImageOpenGLAdditions.h"

#import <OpenGL/glu.h>
#import <OpenGL/gl.h>

static GLboolean renderCapabilitiesChecked = 0;

static GLboolean isTextureRectangle = 0;
static GLint maxRectTextureSize = 0;


static char isPowerOf2(unsigned int n)
{
	int popcnt = 0;
	unsigned int mask = 0x1;
	
	while(mask)
	{
		if(n & mask)
		{
			popcnt++;
		}
		mask = mask << 1;
	}
	
	return (popcnt == 1);
}

NSRect NSRectInsideRect(NSRect a, NSRect b)
{
	float ideal_ratio = b.size.width / b.size.height;
	float view_ratio = a.size.width / a.size.height;
	NSRect bounds;
	float scale;
	
	if(view_ratio < ideal_ratio)
	{
		scale = a.size.width / b.size.width;
	}
	else
	{
		scale = a.size.height / b.size.height;
	}
	
	bounds = NSMakeRect((a.size.width - (b.size.width * scale)) * 0.5,
						(a.size.height - (b.size.height * scale)) * 0.5,
						b.size.width * scale,
						b.size.height * scale);
	
	return bounds;
}


@implementation NSImage (NSImageOpenGLAdditions)

-(void) checkRendererCapabilities
{
	const GLubyte * strVersion;
	const GLubyte * strExt;
	
	strVersion = glGetString (GL_VERSION);
	strExt = glGetString (GL_EXTENSIONS);
	
	isTextureRectangle = gluCheckExtension ((const GLubyte*)
											"GL_EXT_texture_rectangle", strExt);
	if(isTextureRectangle)
	{
		glGetIntegerv (GL_MAX_RECTANGLE_TEXTURE_SIZE_EXT, &maxRectTextureSize);
	}
	
	renderCapabilitiesChecked = 1;
}


-(GLuint) texture:(int)mode
	  compression:(int)compression
// Derived from http://developer.apple.com/qa/qa2001/qa1325.html
{
    // Bitmap generation from source view
    NSBitmapImageRep * bitmap = [NSBitmapImageRep alloc];
	NSBitmapImageRep * color_bitmap = [NSBitmapImageRep alloc];
    int samplesPerPixel = 0;
	GLuint texName;
	NSRect bounds = NSMakeRect(0, 0, 0, 0);
	NSImage * new_image = 0;
	unsigned char * actual_bytes = 0;
	
	int is_power_of_2 = 0;
	unsigned int texture_mode = GL_TEXTURE_RECTANGLE_EXT;
	BOOL isFlipped = [self isFlipped];
	
	bounds.size = [self size];
	
	// Flip it to make it OpenGL friendly in its origin...
	[self setFlipped:!isFlipped];
	
    [self lockFocus];
    [bitmap initWithFocusedViewRect:bounds];
    [self unlockFocus];
	
	[self setFlipped:isFlipped];
	
	if(!renderCapabilitiesChecked)
	{
		[self checkRendererCapabilities];
	}
	
	if(isPowerOf2(bounds.size.width) && 
	   isPowerOf2(bounds.size.height))
	{
		is_power_of_2 = 1;
	}
	
	if(is_power_of_2)
	{
		texture_mode = GL_TEXTURE_2D;
	}
	else
	{
		if(!isTextureRectangle)
		{
			// No texture rectangle extension... we're unable to handle
			// non-power-of-2 textures easily.
			
			fprintf(stderr, "Error: Unable to load non-power-of-2 texture\n");
			
			return -1;
		}
	}
	
	glEnable(texture_mode);
	
    // Set proper unpacking row length for bitmap
    glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
	
    // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps)
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
	
    // Generate new texture object if none passed in
	glGenTextures (1, &texName);
	glBindTexture (texture_mode, texName);
	
    // Non-mipmap filtering (redundant for texture_rectangle)
    glTexParameteri(texture_mode, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(texture_mode, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
    samplesPerPixel = [bitmap samplesPerPixel];
	
	glTexParameteri(texture_mode, GL_TEXTURE_WRAP_S, mode);
	glTexParameteri(texture_mode, GL_TEXTURE_WRAP_T, mode);
		
    // Non-planar, RGB 24 bit bitmap, or RGBA 32 bit bitmap
    if(![bitmap isPlanar] && 
       (samplesPerPixel == 3 || samplesPerPixel == 4))
	{
		actual_bytes = [bitmap bitmapData];
		
		if(compression)
		{
			if(compression == GL_COMPRESSED_RGB_ARB ||
			   compression == GL_COMPRESSED_RGBA_ARB)
			{
				glTexImage2D(texture_mode, 
							 0, 
							 samplesPerPixel == 4 ? GL_COMPRESSED_RGBA_ARB : GL_COMPRESSED_RGB_ARB,
							 [bitmap pixelsWide], 
							 [bitmap pixelsHigh], 
							 0, 
							 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
							 GL_UNSIGNED_BYTE, 
							 actual_bytes);
			}
			
			if(compression == GL_COMPRESSED_RGB_S3TC_DXT1_EXT ||
			   compression == GL_COMPRESSED_RGBA_S3TC_DXT1_EXT)
			{
				glTexImage2D(texture_mode, 
							 0, 
							 samplesPerPixel == 4 ? GL_COMPRESSED_RGBA_S3TC_DXT1_EXT : GL_COMPRESSED_RGB_S3TC_DXT1_EXT,
							 [bitmap pixelsWide], 
							 [bitmap pixelsHigh], 
							 0, 
							 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
							 GL_UNSIGNED_BYTE, 
							 actual_bytes);
			}
			
		}
		else
		{
			glTexImage2D(texture_mode, 
						 0, 
						 samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
						 [bitmap pixelsWide], 
						 [bitmap pixelsHigh], 
						 0, 
						 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
						 GL_UNSIGNED_BYTE, 
						 actual_bytes);
		}
    }
	else
	{
		/*
		 Error condition...
		 The above code handles 2 cases (24 bit RGB and 32 bit RGBA),
		 it is possible to support other bitmap formats if desired.
		 
		 So we'll log out some useful information.
		 */
        NSLog (@"-textureFromView: Unsupported bitmap data format: isPlanar:%d, samplesPerPixel:%d, bitsPerPixel:%d, bytesPerRow:%d, bytesPerPlane:%d",
			   [bitmap isPlanar], 
			   [bitmap samplesPerPixel], 
			   [bitmap bitsPerPixel], 
			   [bitmap bytesPerRow], 
			   [bitmap bytesPerPlane]);
    }
		
	if(color_bitmap)
	{
		[color_bitmap release];
	}
	if(new_image)
	{
		[new_image release];
	}
	
    // Clean up
    [bitmap release];
	
	glDisable(texture_mode);
		
	return texName;
}

-(GLuint) texture:(int)mode
{
	return [self texture:mode
			 compression:0];
}

-(GLuint) texture
{
	return [self texture:GL_CLAMP_TO_BORDER
			 compression:0];
}

- (NSRect) bounds
{
	NSRect r = {0};
	r.size = [self size]; 
	return r;
}

+ (NSImage *) loadImage:(NSString *)image_name
{
	// Have we already been loaded or are we in the normal
	// resource tree?
	NSImage * img = [NSImage imageNamed:image_name];
	
	if(!img)
	{
		// If not, try and treat this like a path to an image file...
		img = [[NSImage alloc] initWithContentsOfFile:image_name];
		
		if(!img)
		{
			// If not, try and get the icon associated with the file...
			img = [[NSWorkspace sharedWorkspace] iconForFile:image_name];
			[img retain];
		}
		
		[img setName:image_name];
	}
	
	return img;
}

+ (NSImage *) loadImage:(NSString *)image_name
		   restrictSize:(NSSize) size
{
	// Have we already been loaded or are we in the normal
	// resource tree?
	NSImage * img = [NSImage imageNamed:image_name];
	NSRect orig_bounds;
	NSRect max_bounds = {0};
	
	if(!img)
	{
		// If not, try and treat this like a path to an image file...
		img = [[NSImage alloc] initWithContentsOfFile:image_name];
		
		if(!img)
		{
			// If not, try and get the icon associated with the file...
			img = [[NSWorkspace sharedWorkspace] iconForFile:image_name];
			[img retain];
		}
	}
	
	// Is the image too big?  If so, resize it...
	orig_bounds = [img bounds];
	max_bounds.size = size;
	if(orig_bounds.size.width > max_bounds.size.width ||
	   orig_bounds.size.height > max_bounds.size.height)
	{
		NSRect new_bounds = NSRectInsideRect(max_bounds, orig_bounds);
		NSImage * new_img = [[NSImage alloc] initWithSize:new_bounds.size];
		
		new_bounds.origin.x = 0.0;
		new_bounds.origin.y = 0.0;
		
		[new_img lockFocus];
		
		[img drawInRect:new_bounds
			   fromRect:orig_bounds
			  operation:NSCompositeSourceOver
			   fraction:1.0];
		
		[new_img unlockFocus];
		
		[new_img setName:image_name];
		
		return new_img;
	}
	
	// Name the image for easy access...
	[img setName:image_name];
	
	return img;
}


- (void)drawAtPoint:(NSPoint)point
		  withScale:(NSSize)scale
		  operation:(NSCompositingOperation)op
		   fraction:(float)delta
{
	NSSize orig_size = [self size];
	NSRect dst_rect;
	
	dst_rect.size.width = scale.width * orig_size.width;
	dst_rect.size.height = scale.height * orig_size.height;
	dst_rect.origin.x = point.x - dst_rect.size.width * 0.5;
	dst_rect.origin.y = point.y - dst_rect.size.height * 0.5;
	
	[self drawInRect:dst_rect
			fromRect:[self bounds]
		   operation:op
			fraction:delta];
}

- (void)drawAtPoint:(NSPoint)point
		  withSize:(NSSize)scale
		  operation:(NSCompositingOperation)op
		   fraction:(float)delta
{
	NSRect dst_rect;
	
	dst_rect.size.width = scale.width;
	dst_rect.size.height = scale.height;
	dst_rect.origin.x = point.x - dst_rect.size.width * 0.5;
	dst_rect.origin.y = point.y - dst_rect.size.height * 0.5;
	
	[self drawInRect:dst_rect
			fromRect:[self bounds]
		   operation:op
			fraction:delta];
}

@end