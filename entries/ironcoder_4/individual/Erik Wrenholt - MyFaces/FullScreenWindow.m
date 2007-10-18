//
//  FullScreenWindow.m
//  MyFaces
//
//  Created by Erik Wrenholt on 10/27/06.
//  Copyright 2006 Timestretch Software. All rights reserved.
//

#import "FullScreenWindow.h"


@implementation FullScreenWindow

-(BOOL)canBecomeKeyWindow
{
	return TRUE;
}

-(BOOL)canBecomeMainWindow
{
	return TRUE;
}

-(BOOL)hidesOnDeactivate
{
	return TRUE;
}


@end
