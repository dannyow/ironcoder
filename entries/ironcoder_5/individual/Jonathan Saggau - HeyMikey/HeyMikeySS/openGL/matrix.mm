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


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define ANG_to_RAD	(float)(M_PI/180.0f)
#define RAD_to_ANG	(float)(180.0f/M_PI)

void glmatrix_identity(float mat[16])
{
	memset(mat, 0x0, sizeof(float) * 16);
	mat[0]=mat[5]=mat[10]=mat[15]=1;
}

void glmatrix_multiply(float a[16],float b[16])
{
	
	float mat[16];
	
	mat[0] = a[0]*b[0]+a[1]*b[4]+a[2]*b[8]+a[3]*b[12];
	mat[1] = a[0]*b[1]+a[1]*b[5]+a[2]*b[9]+a[3]*b[13];
	mat[2] = a[0]*b[2]+a[1]*b[6]+a[2]*b[10]+a[3]*b[14];
	mat[3] = a[0]*b[3]+a[1]*b[7]+a[2]*b[11]+a[3]*b[15];
	
	mat[4] = a[4]*b[0]+a[5]*b[4]+a[6]*b[8]+a[7]*b[12];
	mat[5] = a[4]*b[1]+a[5]*b[5]+a[6]*b[9]+a[7]*b[13];
	mat[6] = a[4]*b[2]+a[5]*b[6]+a[6]*b[10]+a[7]*b[14];
	mat[7] = a[4]*b[3]+a[5]*b[7]+a[6]*b[11]+a[7]*b[15];
	
	mat[8] = a[8]*b[0]+a[9]*b[4]+a[10]*b[8]+a[11]*b[12];
	mat[9] = a[8]*b[1]+a[9]*b[5]+a[10]*b[9]+a[11]*b[13];
	mat[10] = a[8]*b[2]+a[9]*b[6]+a[10]*b[10]+a[11]*b[14];
	mat[11] = a[8]*b[3]+a[9]*b[7]+a[10]*b[11]+a[11]*b[15];
	
	mat[12] = a[12]*b[0]+a[13]*b[4]+a[14]*b[8]+a[15]*b[12];
	mat[13] = a[12]*b[1]+a[13]*b[5]+a[14]*b[9]+a[15]*b[13];
	mat[14] = a[12]*b[2]+a[13]*b[6]+a[14]*b[10]+a[15]*b[14];
	mat[15] = a[12]*b[3]+a[13]*b[7]+a[14]*b[11]+a[15]*b[15];
	
	memmove(a, mat, sizeof(float) * 16);
}

void glmatrix_multiply_vector(float p[3], float m[16], float v[3])
{
	p[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12];
	p[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13];
	p[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14];
}


void glmatrix_rotate_x(float mat[16], register float ang)
{
	register float		rad,r_cos,r_sin;
	
	rad=ang*ANG_to_RAD;
	r_cos=(float)cos(rad);
	r_sin=(float)sin(rad);
	
	glmatrix_identity(mat);
	
	mat[5]=r_cos;
	mat[6]=r_sin;
	mat[9]=-r_sin;
	mat[10]=r_cos;
}

void glmatrix_rotate_y(float mat[16],register float ang)
{
	register float		rad,r_cos,r_sin;
	
	rad=ang*ANG_to_RAD;
	r_cos=(float)cos(rad);
	r_sin=(float)sin(rad);
	
	glmatrix_identity(mat);
	
	mat[0]=r_cos;
	mat[2]=-r_sin;
	mat[8]=r_sin;
	mat[10]=r_cos;
}

void glmatrix_rotate_z(float mat[16],register float ang)
{
	register float		rad,r_cos,r_sin;
	
	rad=ang*ANG_to_RAD;
	r_cos=(float)cos(rad);
	r_sin=(float)sin(rad);
	
	glmatrix_identity(mat);
	
	mat[0]=r_cos;
	mat[1]=r_sin;
	mat[4]=-r_sin;
	mat[5]=r_cos;
}

void glmatrix_rotate_xyz(float mat[16],register float x_ang,register float y_ang,register float z_ang)
{
	float		y_mat[16],z_mat[16];
	
	glmatrix_rotate_x(mat,x_ang);
	
	glmatrix_rotate_y(y_mat,y_ang);
	glmatrix_multiply(mat,y_mat);
	
	glmatrix_rotate_z(z_mat,z_ang);
	glmatrix_multiply(mat,z_mat);
}

void glmatrix_rotate_zyx(float mat[16],register float x_ang,register float y_ang,register float z_ang)
{
	float		x_mat[16],y_mat[16];
	
	glmatrix_rotate_z(mat,z_ang);
	
	glmatrix_rotate_y(y_mat,y_ang);
	glmatrix_multiply(mat,y_mat);
	
	glmatrix_rotate_x(x_mat,x_ang);
	glmatrix_multiply(mat,x_mat);
}

void glmatrix_rotate_xzy(float mat[16],register float x_ang,register float y_ang,register float z_ang)
{
	float		y_mat[16],z_mat[16];
	
	glmatrix_rotate_x(mat,x_ang);
	
	glmatrix_rotate_z(z_mat,z_ang);
	glmatrix_multiply(mat,z_mat);
	
	glmatrix_rotate_y(y_mat,y_ang);
	glmatrix_multiply(mat,y_mat);
}