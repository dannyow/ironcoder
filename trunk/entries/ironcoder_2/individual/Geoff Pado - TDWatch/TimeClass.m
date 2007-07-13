//
//  TimeClass.m
//  TDWatch App
//
//  Created by Geoff Pado on 7/23/06.
//  Copyright 2006 A Clockwork Apple. All rights reserved.
//

#import "TimeClass.h"


@implementation TimeClass

- (void)awakeFromNib
{
	//this code does nothing
	CGRect rect = CGRectMake(0,0,0,0);
	CGRectGetHeight(rect);
	
	NSDate *date = [NSDate date];
	[timeField setStringValue:[date description]];
}

@end
