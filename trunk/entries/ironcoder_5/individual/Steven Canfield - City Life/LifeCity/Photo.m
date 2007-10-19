//
//  Photo.m
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"


@implementation Photo

- (id)initWithContentsOfFile:(NSString *)fileName {
	self = [super init];
	
	if( self ) { 
		CGImageSourceRef image_source = CGImageSourceCreateWithURL( (CFURLRef)[NSURL fileURLWithPath:fileName],NULL);

		CGImageRef image = CGImageSourceCreateImageAtIndex( image_source, 0, NULL);

		unsigned width = CGImageGetWidth(image);
		unsigned height = CGImageGetHeight(image);

		[self setWidth:width];
		[self setHeight:height];

		void *data = malloc(width * height * 4);

		CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();

		CGContextRef context = CGBitmapContextCreate( data, width, height,8,width * 4, CGImageGetColorSpace(image),  kCGImageAlphaPremultipliedLast);

		CGContextTranslateCTM( context , 0.0 , height);
		CGContextScaleCTM( context , 1.0 , -1.0 );
	//	CGContextRotateCTM( context , M_PI );
	//	CGContextConcatCTM( context , CGAffineTransformMakeScale( 1.0 ,-1.0));
		CGContextDrawImage( context, CGRectMake(0, 0, width, height), image);
	
		/*
		CGImageRef output = CGBitmapContextCreateImage( context );
		CGImageDestinationRef dst = CGImageDestinationCreateWithURL([NSURL fileURLWithPath:@"/Users/scanfield/Desktop/1.png"], kUTTypePNG ,1,NULL);
		CGImageDestinationAddImage( dst , output , NULL );
		CGImageDestinationFinalize( dst );
		*/
	
		glGenTextures(1, &textureIndex);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureIndex);
		glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, data);
				
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER,GL_LINEAR);

		CFRelease(context);
		CFRelease(color_space);
		free(data);
		CFRelease(image);
		CFRelease(image_source);
	}
	return self;

}

- (id)initWithIconForFile:(NSString *)fileName {
	self = [super init];
	
	if( self ) { 
		NSImage * image = [[NSWorkspace sharedWorkspace] iconForFile:fileName];
		
	//	CGImageSourceRef image_source = CGImageSourceCreateWithURL( (CFURLRef)[NSURL fileURLWithPath:fileName],NULL);

	//	CGImageRef image = CGImageSourceCreateImageAtIndex( image_source, 0, NULL);

		unsigned width = [image size].width;
		unsigned height = [image size].height;

		[self setWidth:width];
		[self setHeight:height];

		void *data = malloc(width * height * 4);

		CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();

		CGContextRef context = CGBitmapContextCreate( data, width, height,8,width * 4, color_space,  kCGImageAlphaPremultipliedLast);

		CGContextTranslateCTM( context , 0.0 , height);
		CGContextScaleCTM( context , 1.0 , -1.0 );
	//	CGContextRotateCTM( context , M_PI );
	//	CGContextConcatCTM( context , CGAffineTransformMakeScale( 1.0 ,-1.0));
		
		NSGraphicsContext * graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
		[NSGraphicsContext setCurrentContext:graphicsContext];
		
		[image drawInRect:NSMakeRect(0,0,width,height) fromRect:NSMakeRect(0,0,width,height) operation:NSCompositeCopy fraction:1.0];
	//	CGContextDrawImage( context, CGRectMake(0, 0, width, height), image);
	
		/*
		CGImageRef output = CGBitmapContextCreateImage( context );
		CGImageDestinationRef dst = CGImageDestinationCreateWithURL([NSURL fileURLWithPath:@"/Users/scanfield/Desktop/1.png"], kUTTypePNG ,1,NULL);
		CGImageDestinationAddImage( dst , output , NULL );
		CGImageDestinationFinalize( dst );
		*/
	
		glGenTextures(1, &textureIndex);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureIndex);
		glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, data);
				
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER,GL_LINEAR);

		CFRelease(context);
		CFRelease(color_space);
		free(data);
	}
	return self;

}




- (void)set {
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	glBindTexture( GL_TEXTURE_RECTANGLE_ARB , textureIndex) ;
}

- (void)setWidth:(int)width
{
	_width = width;
}

- (int)width
{
	return _width;
}

- (void)setHeight:(int)height
{
	_height = height;
}

- (int)height
{
	return _height;
}

@end
