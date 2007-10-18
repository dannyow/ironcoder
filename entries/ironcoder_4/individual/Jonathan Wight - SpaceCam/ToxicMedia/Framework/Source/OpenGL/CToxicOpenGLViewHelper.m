//
//  CToxicOpenGLViewHelper.m
//  CustomOpenGLView
//
//  Created by Jonathan Wight on 8/15/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CToxicOpenGLViewHelper.h"

#import <OpenGL/gl.h>
#import <QuartzCore/QuartzCore.h>

@implementation CToxicOpenGLViewHelper

+ (NSOpenGLPixelFormat *)defaultPixelFormat
{
NSOpenGLPixelFormatAttribute theAttributes[] = { 0 };
NSOpenGLPixelFormat *theDefaultPixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:theAttributes] autorelease];
return(theDefaultPixelFormat);
}

#pragma mark -

- (void)dealloc
{
[self setView:NULL];
//
[self setPixelFormat:NULL];
[self setOpenGLContext:NULL];
//
[super dealloc];
}

#pragma mark -

- (id)initWithCoder:(NSCoder *)inCoder 
{
if ((self = [self init]) != NULL)
	{
	[self setPixelFormat:[inCoder decodeObjectForKey:@"pixelFormat"]];
    }
return(self);
}

- (void)encodeWithCoder:(NSCoder *)inCoder 
{
[inCoder encodeObject:pixelFormat forKey:@"pixelFormat"];
}

#pragma mark -

- (NSView *)view
{
return(view); 
}

- (void)setView:(NSView *)inView
{
if (view != NULL)
	{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewGlobalFrameDidChangeNotification object:view];
	}
view = inView;
if (view != NULL)
	{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewGlobalFrameDidChangeNotification:) name:NSViewGlobalFrameDidChangeNotification object:view];
	}
}

#pragma mark -

- (NSOpenGLPixelFormat *)pixelFormat
{
if (pixelFormat == NULL)
	{
	[self setPixelFormat:[[self class] defaultPixelFormat]];
	}
return(pixelFormat); 
}

- (void)setPixelFormat:(NSOpenGLPixelFormat *)inPixelFormat
{
if (pixelFormat != inPixelFormat)
    {
	[pixelFormat autorelease];
	pixelFormat = [inPixelFormat retain];
    }
}

- (NSOpenGLContext *)openGLContext
{
if (openGLContext == NULL)
	{
	NSOpenGLContext *theContext = [[[NSOpenGLContext alloc] initWithFormat:[self pixelFormat] shareContext:NULL] autorelease];
	[self setOpenGLContext:theContext];
	}
return(openGLContext); 
}

- (void)setOpenGLContext:(NSOpenGLContext *)inOpenGLContext
{
if (openGLContext != inOpenGLContext)
    {
	if (openGLContext != NULL)
		{
        if ([openGLContext view] == [self view])
			{
            [openGLContext clearDrawable];
			}
        [openGLContext autorelease];
        openGLContext = NULL;
		}

	if (inOpenGLContext)
		{
		openGLContext = [inOpenGLContext retain];
		[openGLContext makeCurrentContext];
		}
    }
}

- (CIContext *)coreImageContext
{
// Create the CoreImage context...
CGLContextObj theGLContext = [[self openGLContext] CGLContextObj];
CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
CGLPixelFormatObj thePixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:
	(id)theColorSpace, kCIContextOutputColorSpace,
	(id)theColorSpace, kCIContextWorkingColorSpace,
	NULL]; 
CIContext *theCIContext = [CIContext contextWithCGLContext:theGLContext pixelFormat:thePixelFormat options:theOptions];
if (theCIContext == NULL) [NSException raise:NSGenericException format:@"Could not create a CIContext"];
CGColorSpaceRelease(theColorSpace);
return(theCIContext);
}

#pragma mark -

- (void)lockFocus
{
if ([[self openGLContext] view] != [self view])
	{
	[[self openGLContext] setView:[self view]];
    }

[[self openGLContext] makeCurrentContext];
}

- (void)unlockFocus
{
}

- (void)update
{
if (openGLContext != NULL && [[self openGLContext] view] == [self view])
	{
	[[self openGLContext] update];
	}
}

#pragma mark -

- (void)viewGlobalFrameDidChangeNotification:(NSNotification *)inNotification
{
#pragma unused (inNotification)

[self update];
}

@end
