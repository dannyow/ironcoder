/*
 *  Spline.c
 *  Wildcat
 *
 *  Created by Nur Monson on 3/30/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "Spline.h"

heightSplineRef SplineCreateHeight( unsigned int pointCount, float deltaH )
{
	heightSplineRef newSpline = (heightSplineRef)malloc( sizeof(heightSpline) + pointCount*(sizeof(float)+sizeof(Vector2D)) );
	if( newSpline == NULL )
		return NULL;
	
	newSpline->pointCount = pointCount;
	newSpline->heights = (float *)((unsigned char *)newSpline + sizeof(heightSpline));
	newSpline->slopes = (Vector2D *)((unsigned char *)newSpline->heights + pointCount*sizeof(float) );
	newSpline->deltaH = deltaH;
	
	return newSpline;
}
void SplineHeightRelease( heightSplineRef aSpline )
{
	free( aSpline );
}

Vector2D SplineGetIntermediatePoint( heightSplineRef aSpline, unsigned int pointIndex, float t )
{
	//if( pointIndex < aSpline->pointCount || pointIndex >=  aSpline->pointCount )
	//	return (Vector2D){0.0f, 0.0f};
	
	Vector2D p0,p1,p2,p3;
	p0.x = 0.0f;
	p1.x = aSpline->deltaH * 0.25f;
	p2.x = aSpline->deltaH * 0.75f;
	p3.x = aSpline->deltaH;
	
	if( pointIndex == aSpline->pointCount-1 ) {
		p0.y = p1.y = aSpline->heights[pointIndex];
		p2.y = p3.y = aSpline->heights[0];
	} else {
		p0.y = p1.y = aSpline->heights[pointIndex];
		p2.y = p3.y = aSpline->heights[pointIndex+1];
	}
	

	Vector2D result;
	float blend;
	float oneMinusT = 1.0f-t;
	
	blend = oneMinusT * oneMinusT * oneMinusT;
	result.x = blend * p0.x;
	result.y = blend * p0.y;
	
	blend = 3.0f * t * oneMinusT * oneMinusT;
	result.x += blend * p1.x;
	result.y += blend * p1.y;
	
	blend = 3.0f * t * t * oneMinusT;
	result.x += blend * p2.x;
	result.y += blend * p2.y;
	
	blend = t * t * t;
	result.x += blend * p3.x;
	result.y += blend * p3.y;
	
	return result;
}

void SplineCalculateSlopeAtPoint( heightSplineRef aSpline, unsigned int pointIndex )
{
	Vector2D p0,p1,p2;
	
	p0.x = 0;
	p1.x = aSpline->deltaH;
	p2.x = p1.x+aSpline->deltaH;
	
	p1.y = aSpline->heights[pointIndex];
	if( pointIndex == 0 ) {
		p0.y = aSpline->heights[aSpline->pointCount-1];
		p2.y = aSpline->heights[pointIndex+1];
	} else if( pointIndex == aSpline->pointCount-1 ) {
		p0.y = aSpline->heights[pointIndex-1];
		p2.y = aSpline->heights[0];
	} else {
		p0.y = aSpline->heights[pointIndex-1];
		p2.y = aSpline->heights[pointIndex+1];
	}
	
	float s1 = (p1.y-p0.y)/(p1.x-p0.x);
	float s2 = (p2.y-p1.y)/(p2.x-p1.x);
	
	Vector2D n1 = (Vector2D){1.0f, s1};
	Vector2D n2 = (Vector2D){1.0f, s2};
	
	aSpline->slopes[pointIndex] = Vector2DNormalize( (Vector2D){(n1.x+n2.x)/2.0f,(n1.y+n2.y)/2.0f});
}

Vector2D SplineGetIntermediateSlope( heightSplineRef aSpline, unsigned int pointIndex, float t )
{
	Vector2D s1 = aSpline->slopes[pointIndex];
	Vector2D s2;
	
	if( pointIndex == aSpline->pointCount-1 )
		s2 = aSpline->slopes[0];
	else
		s2 = aSpline->slopes[pointIndex+1];
	
	Vector2D result;
	result.x = (s2.x*t+s1.x*(1.0f-t));
	result.y = (s2.y*t+s1.y*(1.0f-t));
	
	return Vector2DNormalize(result);
}

Vector2D Vector2DNormalize( Vector2D v )
{
	float length = sqrtf(v.x*v.x + v.y*v.y);
	v.x /= length;
	v.y /= length;
	
	return v;
}
