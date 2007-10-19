//
//  LifeCityView.h
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "LifeCityOpenGLView.h"
#import "GLDebug.h"

@interface LifeCityView : ScreenSaverView 
{
	LifeCityOpenGLView * openGLView;
}

@end
