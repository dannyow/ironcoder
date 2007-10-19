//
//  Photo.h
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

@interface Photo : NSObject {
	GLuint textureIndex;
	float _width;
	float _height;
}

- (id)initWithIconForFile:(NSString *)fileName;
- (id)initWithContentsOfFile:(NSString *)fileName;
- (void)set;

- (void)setWidth:(int)width;
- (int)width;
- (void)setHeight:(int)height;
- (int)height;

@end
