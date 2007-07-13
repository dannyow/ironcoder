//
//  TimeFormatter.m
//  TapDance
//
//  Created by Michael Ash on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TimeFormatter.h"


@implementation TimeFormatter

- (NSString *)stringForObjectValue:(id)obj
{
	if( ![obj respondsToSelector: @selector( doubleValue )] )
		return nil;
	
	unsigned long long val = llrint( [obj doubleValue] * 100.0 );
	
	int fract = val % 100;
	val /= 100;
	
	int secs = val % 60;
	val /= 60;
	
	int mins = val % 60;
	val /= 60;
	
	int hours = val;
	
	return [NSString stringWithFormat: @"%02d:%02d:%02d.%02d", hours, mins, secs, fract];
}

@end
