/*
 *  normals.h
 *  Exercise 20
 *
 *  Created by Jonathan Saggau on 9/21/06.
 *  Copyright 2006 Jonathan Saggau. All rights reserved.
 *
 */
//http://www.gamedev.net/reference/articles/article1682.asp

void crossProduct(float *c,float a[3], float b[3]);
void normalize(float *vect);
void getFaceNormal(float *norm,float pointa[3],float pointb[3],float pointc[3]);