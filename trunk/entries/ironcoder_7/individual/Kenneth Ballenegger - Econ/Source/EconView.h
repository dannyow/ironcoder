//
//  EconView.h
//  Econ
//
//  Created by Kenneth Ballenegger on 2007/11/17.
//  Copyright (c) 2007, Azure Talon. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <Quartz/Quartz.h>
#import "MyOpenGLView.h"


@interface EconView : ScreenSaverView 
{
	NSArray *icons;
	//Threading
	BOOL didCalc;
	BOOL didStartAnim;
	BOOL didDrawLoading;
	//Quartz Composition
	MyOpenGLView *glView;
	QCRenderer *renderer;
	NSTimeInterval startTime;	
}

- (void)calculationThread:(id)obj;

@end
