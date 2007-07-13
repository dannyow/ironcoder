//
//  CSandboxRenderer.h
//  FallingSand
//
//  Created by Jonathan Wight on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSandbox;

typedef enum {
	RenderingMode_Normal,
	RenderingMode_Density,
} ERenderingMode;

@interface CSandboxRenderer : NSObject {
	CSandbox *sandbox;

	NSMutableData *sandBitmapBuffer;
	CGContextRef sandContext;

	CGImageRef image;
	}

- (CSandbox *)sandbox;
- (void)setSandbox:(CSandbox *)inSandbox;

- (NSMutableData *)sandBitmapBuffer;
- (CGContextRef)sandContext;

- (CGImageRef)image;

- (void)render;
- (void)renderWithMode:(ERenderingMode)inMode;

- (void)reset;

@end
