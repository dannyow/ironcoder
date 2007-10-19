//
//  QuarzWindow.m
//  Sleeper
//
//  Created by Karsten Kusche on 31.03.07.
//  Copyright 2007 briksoftware.com. All rights reserved.
//

#import "QuarzWindow.h"
#import <Quartz/Quartz.h>

@implementation QuarzWindow

- (void)setContentViewWithRect:(NSRect)contentRect
{
	QCView* qView = [[QCView alloc] initWithFrame:contentRect];
	[self setContentView:qView];
	[qView setAutostartsRendering:YES];
}

- (BOOL)showFile:(NSString*)path
{
	return [(QCView*)[self contentView] loadCompositionFromFile:path];
}

@end
