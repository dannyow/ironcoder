/*
 *  Spline.h
 *  Wildcat
 *
 *  Created by Nur Monson on 3/30/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */

typedef struct Vector2D {
	float x;
	float y;
} Vector2D;

typedef struct heightSpline {
	float *heights;
	Vector2D *slopes;
	float deltaH;
	unsigned int pointCount;
} heightSpline;

typedef heightSpline* heightSplineRef;

heightSplineRef SplineCreateHeight( unsigned int pointCount, float deltaH );
void SplineHeightRelease( heightSplineRef aSpline );

Vector2D SplineGetIntermediatePoint( heightSplineRef aSpline, unsigned int pointIndex, float t );
void SplineCalculateSlopeAtPoint( heightSplineRef aSpline, unsigned int pointIndex );
Vector2D SplineGetIntermediateSlope( heightSplineRef aSpline, unsigned int pointIndex, float t );
Vector2D Vector2DNormalize( Vector2D v );