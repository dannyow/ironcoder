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

#import <OpenGL/glu.h>
#import <OpenGL/gl.h>


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <zlib.h>
#include "png.h"


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

#pragma mark -

void png_checkForExtensions()
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

int png_load(const char * path,
			 unsigned char ** bytes,
			 unsigned int * format,
			 int * out_width,
			 int * out_height)
{
	unsigned char sig[8];
	
	FILE * infile;
	png_structp png_ptr;
	png_infop info_ptr, end_ptr;
	
	int i, width, height, rowbytes, channels;
	png_bytep * row_pointers;
	
	unsigned char * bytes_ptr;
	
	*out_width = 0;
	*out_height = 0;
	*bytes = 0;
	*format = 0;
	
	infile = fopen(path, "rb");
	if(!infile)
	{
		return 0;
	}
	
	/* Check for the 8-byte signature */
	fread(sig, 1, 8, infile);
	if(!png_check_sig((unsigned char *) sig, 8))
	{
		fclose(infile);
		return 0;
	}
	
	/* 
		* Set up the PNG structs 
	 */
	png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING,
									 NULL, NULL, NULL);
	if(!png_ptr)
	{
		fclose(infile);
		return 0;
	}
	
	info_ptr = png_create_info_struct(png_ptr);
	if(!info_ptr)
	{
		png_destroy_read_struct(&png_ptr, (png_infopp) NULL, (png_infopp) NULL);
		fclose(infile);
		return 0;
	}
	
	end_ptr = png_create_info_struct(png_ptr);
	if(!end_ptr)
	{
		png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp) NULL);
		fclose(infile);
		return 0;
	}
	
	
	png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (!png_ptr)
	{
		fclose(infile);
		return 0;
	}
	
	info_ptr = png_create_info_struct(png_ptr);
	if (!info_ptr)
	{
		png_destroy_read_struct(&png_ptr, (png_infopp) NULL, (png_infopp) NULL);
		fclose(infile);
		return 0;
	}
	
	end_ptr = png_create_info_struct(png_ptr);
	if (!end_ptr)
	{
		png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp) NULL);
		fclose(infile);
		return 0;
	}
	
	/*
	 * block to handle libpng errors, 
	 * then check whether the PNG file had a bKGD chunk
	 */
	if (setjmp(png_jmpbuf(png_ptr)))
	{
		png_destroy_read_struct(&png_ptr, &info_ptr, &end_ptr);
		fclose(infile);
		return 0;
	}
	
	/*
	 * takes our file stream pointer (infile) and 
	 * stores it in the png_ptr struct for later use.
	 */
	png_ptr->io_ptr = (png_voidp)infile;
	
	/*
	 * lets libpng know that we already checked the 8 
	 * signature bytes, so it should not expect to find 
	 * them at the current file pointer location
	 */
	png_set_sig_bytes(png_ptr, 8);
	
	
	png_read_info(png_ptr, info_ptr);
	
	width = info_ptr->width;
	height = info_ptr->height;
	rowbytes = info_ptr->rowbytes;
	
	channels = png_get_channels(png_ptr, info_ptr);
	
	png_set_interlace_handling(png_ptr);
	png_read_update_info(png_ptr, info_ptr);
	
	row_pointers = (png_bytep *)malloc(sizeof(png_bytep) * height);
	if(!row_pointers)
	{
		return 0;
	}
	
	for (i = 0; i != height; i++)
	{
		row_pointers[i] = (png_byte *)malloc(rowbytes);
		if(!row_pointers[i])
		{
			return 0;
		}
	}
	
	png_read_image(png_ptr, row_pointers);
	
	if(channels == 4)
	{
		*format = GL_RGBA;
	}
	else
	{
		*format = GL_RGB;
	}
	
	*bytes = (unsigned char *)malloc(rowbytes * height);
	if(!*bytes)
	{
		return 0;
	}
	
	bytes_ptr = *bytes;
	for(i = height-1; i >= 0; i--)
	{
		memmove(bytes_ptr, row_pointers[i], rowbytes);
		bytes_ptr += rowbytes;
	}
	
	for (i = 0; i != height; i++)
	{
		free(row_pointers[i]);
	}
	
	free(row_pointers);
	
	png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
	fclose(infile);
	
	*out_width = width;
	*out_height = height;
	
	{
		FILE * out_file = fopen("/temp.raw", "w");
		if(out_file)
		{
			fwrite(*bytes, 1, rowbytes * height, out_file);
			
			fclose(out_file);
		}
	}
	
	return  1;
}

int png_texture(const char * path, int mode)
{
	unsigned char * image_data = 0;
	unsigned int format;
	int width, height;
	
	int is_power_of_2 = 0;
	unsigned int texture_mode = GL_TEXTURE_RECTANGLE_EXT;
	
	GLuint texName;
	
	if(!renderCapabilitiesChecked)
	{
		png_checkForExtensions();
	}
	
	if(!png_load(path, &image_data, &format, &width, &height))
	{
        fprintf(stderr, "Error: Unable to load texture\n");
		return -1;
	}
	
	if(isPowerOf2(width) && 
	   isPowerOf2(height))
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
	glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
	
	// Set byte aligned unpacking (needed for 3 byte per pixel bitmaps)
	glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
	
	// Generate new texture object if none passed in
	glGenTextures (1, &texName);
	glBindTexture (texture_mode, texName);
	
	// Non-mipmap filtering (redundant for texture_rectangle)
	glTexParameteri(texture_mode, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(texture_mode, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glTexParameteri(texture_mode, GL_TEXTURE_WRAP_S, mode);
	glTexParameteri(texture_mode, GL_TEXTURE_WRAP_T, mode);
	
	glTexImage2D(texture_mode, 
				 0, 
				 format == GL_RGBA ? GL_RGBA8 : GL_RGB8,
				 width,
				 height,
				 0, 
				 format,
				 GL_UNSIGNED_BYTE, 
				 image_data);
	
	free(image_data);
	
	glDisable(texture_mode);
	
	return texName;
}
