//
//  WildcatView.h
//  Wildcat
//
//  Created by Nur Monson on 3/30/07.
//  Copyright (c) 2007, theidiotproject. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <QuartzCore/QuartzCore.h>

#import "World.h"

@interface WildcatView : ScreenSaverView 
{
	NSOpenGLPixelFormat *_pixelFormat;
	NSOpenGLContext *_openGLContext;
	NSSize _contextSize;
	BOOL _isFirstFrame;
	BOOL _needsReshape;
	
	World *_world;
	
	float _position;
	
	NSAnimation *_cameraAnimation;
	float _cameraDestination;
	float _cameraTravelDistance;
	float _cameraOldLocation;
}

@end
