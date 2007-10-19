//
//  Rectangle.h
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import "Photo.h"


@interface Rectangle : NSObject {
	NSColor *	_color;
	NSRect		_rect;
	float Z;
	Photo * texture;
}
- (id)initWithRect:(NSRect)r Z:(float)z;
- (void)setTexture:(Photo *)tex;
- (void)draw;
- (void)setColor:(NSColor *)myColor;
@end
