//
//  TIPTexture.m
//  Blocks
//
//  Created by Nur Monson on 2/4/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TIPTexture.h"


@implementation TIPTexture

- (id)init
{
	if( (self = [super init]) ) {
		theTextureID = 0;
		theTextureSize = NSZeroSize;
	}

	return self;
}

- (void)dealloc
{
	if( theTextureID != 0 ) {
		glDeleteTextures(1, &theTextureID);
		theTextureSize = NSZeroSize;
	}

	[super dealloc];
}

- (id)initWithPNG:(NSString *)imagePath
{
	if( (self = [self init]) ) {

		NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
		CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageURL, NULL);
		if (!(CGImageSourceGetCount(imageSource) > 0))
			printf("ERROR: image source not > 0\n");
		CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
		
		
		unsigned width = CGImageGetWidth(image);
		unsigned height = CGImageGetHeight(image);
		
		void *textureData = malloc(width * height * 4); // faster if 16-byte aligned
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(
													 textureData,
													 width, height,
													 8,				// bitsPerComponent
													 width * 4,		// bytesPerRow (faster if 16-byte aligned)
													 colorSpace,
													 kCGImageAlphaPremultipliedLast);

		CGContextTranslateCTM(context,0.0f,(float)height);
		CGContextScaleCTM(context,1.0f,-1.0f);
		CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
		
		glGenTextures( 1, &theTextureID );
		glBindTexture( GL_TEXTURE_2D, theTextureID );
		
		//glTexParameteri( GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_TRUE );
		glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
		/*
		glTexImage2D( GL_TEXTURE_2D, 0,
					  GL_RGBA,
					  width, height,
					  0,
					  GL_RGBA,
					  GL_UNSIGNED_BYTE,	// i.e., GL_ARGB
													//GL_RGBA,
													//GL_UNSIGNED_BYTE,
					  textureData );
		 */
		GLenum result = glGetError();
		if( result != GL_NO_ERROR )
			printf("error! %0x\n", (unsigned int) result);
		/*
		glTexParameteri( GL_TEXTURE_2D,	GL_TEXTURE_WRAP_S,
						 GL_CLAMP_TO_EDGE_SGIS );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
						 GL_CLAMP_TO_EDGE_SGIS );
		 */
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
						 GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
						 GL_LINEAR                          );
		
		theTextureSize.width = width;
		theTextureSize.height = height;
		
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		free(textureData);
		CGImageRelease(image);
		CFRelease(imageSource);
	}
	
	return self;
}

- (NSSize)size
{
	return theTextureSize;
}
- (GLuint)textureID
{
	return theTextureID;
}

@end
