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

#ifndef _PNG_H_
#define _PNG_H_

#pragma mark *** Includes ***

#pragma mark *** Definitions ***

#pragma mark *** Prototypes ***

extern void png_checkForExtensions();
extern int png_texture(const char * path, int mode);

extern int png_load(const char * path,
					unsigned char ** bytes,
					unsigned int * format,
					int * out_width,
					int * out_height);

#endif