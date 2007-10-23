/**********************************************************************

Created by Rocco Bowling
Big Nerd Ranch, Inc
OpenGL Bootcamp

Copyright 2006 Rocco Bowling, All rights reserved.

/***************************** License ********************************

This code can be freely used as long as these conditions are met:

1. This header, in its entirety, is kept with the code
3. It is not resold, in it's current form or in modified, as a
teaching utility or as part of a teaching utility

This code is presented as is. The author of the code takes no
responsibilities for any version of this code.

(c) 2006 Rocco Bowling

*********************************************************************/

#ifndef _GL_MATRIX_MATH_H_
#define _GL_MATRIX_MATH_H_

extern void glmatrix_identity(float mat[16]);
extern void glmatrix_multiply(float a[16],float b[16]);
extern void glmatrix_multiply_vector(float p[3], float m[16], float v[3]);
extern void glmatrix_rotate_x(float mat[16], register float ang);
extern void glmatrix_rotate_y(float mat[16],register float ang);
extern void glmatrix_rotate_z(float mat[16],register float ang);
extern void glmatrix_rotate_xyz(float mat[16],register float x_ang,register float y_ang,register float z_ang);
extern void glmatrix_rotate_zyx(float mat[16],register float x_ang,register float y_ang,register float z_ang);
extern void glmatrix_rotate_xzy(float mat[16],register float x_ang,register float y_ang,register float z_ang);



#endif