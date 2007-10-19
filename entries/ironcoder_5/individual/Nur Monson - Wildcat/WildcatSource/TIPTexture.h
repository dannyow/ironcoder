//
//  TIPTexture.h
//  Blocks
//
//  Created by Nur Monson on 2/4/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <Opengl/Opengl.h>



@interface TIPTexture : NSObject {
	GLuint theTextureID;
	NSSize theTextureSize;
}

- (id)initWithPNG:(NSString *)imagePath;

- (NSSize)size;
- (GLuint)textureID;
@end
