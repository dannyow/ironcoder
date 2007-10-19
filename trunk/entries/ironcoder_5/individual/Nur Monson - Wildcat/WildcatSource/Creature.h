//
//  Creature.h
//  Wildcat
//
//  Created by Nur Monson on 3/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <ScreenSaver/ScreenSaver.h>
#import "Spline.h"
#import "TIPTexture.h"

@interface Creature : NSObject {
	float _position;
	Vector2D _velocity;
	int _bounce;
	float _worldSize;
	TIPTexture *_texture;
	
	int _age;
	
	NSColor *_color;
}

+ (TIPTexture *)sharedTexture;

- (float)position;
- (void)setTexture:(TIPTexture *)aTexture;
- (TIPTexture *)texture;
- (int)age;

- (void)setColor:(NSColor *)aColor;
- (NSColor *)color;

- (void)randomize:(float)worldSize;
- (void)simulate;

- (void)drawWithSlope:(Vector2D)slope;
@end
