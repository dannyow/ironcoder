//
//  World.h
//  Wildcat
//
//  Created by Nur Monson on 3/30/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Spline.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <ScreenSaver/ScreenSaver.h>
#import "Creature.h"

@interface World : NSObject {
	heightSplineRef _landSpline;
	float _size;
	
	NSMutableArray *_creatures;
	
	TIPTexture *_creatureTexture;
	TIPTexture *_rockTexture;
	TIPTexture *_grassTexture;
	TIPTexture *_snowTexture;
	
	GLuint _fragmentShader;
	GLuint _vertexShader;
	GLuint _mainProgram;
}

- (float)size;
- (void)drawRangeStart:(float)rangeStart width:(float)rangeWidth;

@end
