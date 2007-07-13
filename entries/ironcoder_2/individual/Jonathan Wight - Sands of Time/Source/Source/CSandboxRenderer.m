//
//  CSandboxRenderer.m
//  FallingSand
//
//  Created by Jonathan Wight on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CSandboxRenderer.h"

#import "CSandbox.h"

@implementation CSandboxRenderer

- (void)dealloc
{
[self setSandbox:NULL];
//
[self reset];
//
[super dealloc];
}

- (CSandbox *)sandbox
{
return(sandbox);
}

- (void)setSandbox:(CSandbox *)inSandbox
{
if (sandbox != inSandbox)
	{
	[sandbox autorelease];
	sandbox = [inSandbox retain];
	}
}

- (NSMutableData *)sandBitmapBuffer
{
if (sandBitmapBuffer == NULL)
	{
	const size_t theBufferLength = [[self sandbox] width] * 4 * [[self sandbox] height];
	sandBitmapBuffer = [[NSMutableData alloc] initWithLength:theBufferLength];
	}
return(sandBitmapBuffer);
}

- (CGContextRef)sandContext
{
if (sandContext == NULL)
	{
	CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
	
	sandContext = CGBitmapContextCreate([[self sandBitmapBuffer] mutableBytes], [[self sandbox] width], [[self sandbox] height], 8, [[self sandbox] width] * 4, theColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
	if (sandContext == NULL) [NSException raise:NSGenericException format:@"CGBitmapContextCreate() failed."];
	
	CFRelease(theColorSpace);
	}
return(sandContext);
}

- (CGImageRef)image
{
return(image);
}

- (void)render
{
[self renderWithMode:RenderingMode_Normal];
}

- (void)renderWithMode:(ERenderingMode)inMode
{
UInt32 *theBitmapPointer = [[self sandBitmapBuffer] mutableBytes];

const size_t theWidth = [[self sandbox] width];
const size_t theHeight = [[self sandbox] height];
SCell *theSand = [[[self sandbox] sandBuffer] mutableBytes];

SParticleTemplate *theParticleTemplates = [[self sandbox] particleTemplates];

if (inMode == RenderingMode_Normal)
	{
	for (unsigned Y = 0; Y != theHeight; ++Y)
		{
		for (unsigned X = 0; X != theWidth; ++X)
			{
			EParticleType theParticleType = theSand[Y * theWidth + X].particle.type;
			UInt32 theColor = theParticleTemplates[theParticleType].color;
			theBitmapPointer[(theHeight - Y) * theWidth + X] = theColor;
			}
		}
	}
else if (inMode == RenderingMode_Density)
	{
	for (unsigned Y = 0; Y != theHeight; ++Y)
		{
		for (unsigned X = 0; X != theWidth; ++X)
			{
			const EParticleType theParticleType = theSand[Y * theWidth + X].particle.type;
			const UInt32 theIntensity = (UInt8)theParticleTemplates[theParticleType].density * 255.0f; 
			const UInt32 theColor = theIntensity << 16 | theIntensity << 8 | theIntensity;
//			const UInt32 theColor = theIntensity << 8;
			theBitmapPointer[(theHeight - Y) * theWidth + X] = theColor;
			}
		}
	}

CGImageRef theImage = CGBitmapContextCreateImage([self sandContext]);

if (image != NULL)
	{
	CFRelease(image);
	image = NULL;
	}
	
image = theImage;
}

- (void)reset
{
if (sandContext != NULL)
	{
	CFRelease(sandContext);
	sandContext = NULL;
	}
	
if (sandBitmapBuffer != NULL)
	{
	[sandBitmapBuffer autorelease];
	sandBitmapBuffer = NULL;
	}

if (image != NULL)
	{
	CFRelease(image);
	image = NULL; 
	}
}

@end
