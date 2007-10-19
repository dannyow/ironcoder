//
//  Life_PlayerView.h
//  Life Player
//
//  Created by Geoff Pado on 3/30/07.
//  Copyright (c) 2007, A Clockwork Apple. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "ICOpenGLView.h"

@interface Life_PlayerView : ScreenSaverView 
{
	ICOpenGLView *glView;
	GLfloat rotation;
	GLfloat translation;
	GLfloat xValue;
	
	GLenum texFormat[ 1 ];   // Format of texture (GL_RGB, GL_RGBA)
   NSSize texSize[ 1 ];     // Width and height
   char *texBytes[ 1 ];     // Texture data
   GLuint texture[ 1 ];     // Storage for one texture
	
	NSMutableArray *filePaths;
	NSImageView *drawImageView;
	NSImage *currentImage;
	NSPoint currentPoint;
	int i;
	int animFrame;
}

- (void)setUpOpenGL;

@end
