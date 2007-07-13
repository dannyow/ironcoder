/*
 *  T3MouseLapseUtilty.h
 *  MouseLapse
 *
 *  Created by 23 on 7/21/06.
 *  Copyright 2006 23. All rights reserved.
 *
 */
 
 
static __inline__ CGRect CGRectMakeFromNSRect( NSRect* rect )
{
	CGRect newRect;
	
	newRect.size.width = rect->size.width;
	newRect.size.height = rect->size.height;
	
	newRect.origin.x = rect->origin.x;
	newRect.origin.y = rect->origin.y;
	
	return newRect;
} 

