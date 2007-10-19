//
//  WildcatView.m
//  Wildcat
//
//  Created by Nur Monson on 3/30/07.
//  Copyright (c) 2007, theidiotproject. All rights reserved.
//

#import "WildcatView.h"


@implementation WildcatView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if( (self = [super initWithFrame:frame isPreview:isPreview]) ) {
		[self setAnimationTimeInterval:1/30.0];
		
		NSOpenGLPixelFormatAttribute attribs[] = {
			NSOpenGLPFAWindow,
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAColorSize, 24,
			NSOpenGLPFAAlphaSize, 8,
			0 };
		
		_pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
		_openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:nil];
		
		if( _openGLContext == nil )
			printf("failed to create the OpenGLContext\n");
		
		long vsync = 1;
		[_openGLContext setValues:&vsync forParameter:NSOpenGLCPSwapInterval];
		
		_isFirstFrame = YES;
		
		_world = [[World alloc] init];
		_cameraAnimation = [[NSAnimation alloc] initWithDuration:SSRandomFloatBetween(1.0f,2.0f) animationCurve:NSAnimationEaseInOut];
		[_cameraAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		_cameraDestination = SSRandomFloatBetween(0.0f,[_world size]);
		
		_position = 0.0f;
    }
    return self;
}

-  (void)dealloc
{
	[_openGLContext release];
	[_pixelFormat release];
	
	[_world release];
	[_cameraAnimation release];
	
	[super dealloc];
}

#pragma mark stock

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

#pragma mark Drawing

- (void)moveCamera
{
	if( ![_cameraAnimation isAnimating] ) {
		_cameraOldLocation = _cameraDestination;
		_cameraDestination = SSRandomFloatBetween(0.0f,[_world size]);
		[_cameraAnimation setDuration:(NSTimeInterval)SSRandomFloatBetween(2.0f,5.0f)];
		[_cameraAnimation startAnimation];
	}
	
	float distance = _cameraDestination - _cameraOldLocation;
	if( fabsf(distance) < fabsf(distance-[_world size]) )
		_cameraTravelDistance = distance;
	else
		_cameraTravelDistance = distance-[_world size];
	
	_position = _cameraOldLocation + _cameraTravelDistance * [_cameraAnimation currentValue];
	if( _position < 0.0f )
		_position += [_world size];
	else if( _position > [_world size] )
		_position -= [_world size];
}

- (void)doReshape
{
	_contextSize = [self bounds].size;
	
	[_openGLContext update];
	glViewport(0.0f, 0.0f, _contextSize.width, _contextSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glOrtho(0.0f, _contextSize.width/_contextSize.height, 0.0f, 1.0f, 300.0f, -300.0f);
	
	glMatrixMode(GL_MODELVIEW);
	
	_needsReshape = NO;
}

- (void)firstFrameSetup
{
	[_openGLContext setView:self];
	[_openGLContext makeCurrentContext];
	
	glEnable(GL_TEXTURE_2D);
	//glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	//glEnable(GL_LINE_SMOOTH);
	//glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
	
	_contextSize = NSZeroSize;
	
	_isFirstFrame = NO;
	_needsReshape = YES;
}

- (void)animateOneFrame
{
	if( _isFirstFrame )
		[self firstFrameSetup];
	
	[_openGLContext makeCurrentContext];
	NSSize boundSize = [self bounds].size;
	if( _contextSize.width != boundSize.width || _contextSize.height != boundSize.height )
		[self doReshape];
	
	glClearColor(0.0f,0.0f,0.0f,1.0f);
	glClear( GL_COLOR_BUFFER_BIT );
	
	[_world drawRangeStart:_position width:_contextSize.width/_contextSize.height];
	[self moveCamera];
	/*_position += 0.01f;
	if( _position >= [_world size] )
		_position -= [_world size];
	*/
	//printf("position = %.03f\n", _position);
	
	[_openGLContext flushBuffer];
}

@end
