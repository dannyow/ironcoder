//
//  TTCategoryNSColor.m
//  SpaceTime
//
//  Created by 23 on 10/28/06.
//  Copyright 2006 23. All rights reserved.
//

#import "TTCategoryNSColor.h"

//----- constants

const	float			kDefaultSatuartion	=	0.4;
const	float			kDefaultBrightness	=	1.0;

@implementation NSColor (TTCategoryNSColor)

+ (NSColor*) randomStarColor
{
	float hue = rand() / (float)RAND_MAX;

	//----- keep the hues mostly red, yellow and blue
	
	if ( hue > 0.85 )
	{		  
	  hue = 0.5 + ( ( 0.6 - 0.5 ) * ( hue - 0.85) * 6.6666 );
	}
	else
	{
	
		hue = ( 0.1 ) * ( hue ) * 1.1765 ;
	}

	NSColor* starColor = [ NSColor colorWithCalibratedHue:hue
											   saturation:kDefaultSatuartion
												brightness:kDefaultBrightness
													 alpha:1.0 ];

	return starColor;
}

- (CIColor*) coreImageColor
{
	return [ [ [ CIColor alloc ] initWithColor:self ] autorelease ];
}



@end
