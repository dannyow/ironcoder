//
//  CCVStream.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/29/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCVStream.h"

#import "QTMovie_Extensions.h"
#import "CIImage_Extensions.h"
#import "NSOpenGLContext_Extensions.h"

static CVReturn MyCVDisplayLinkOutputCallback(CVDisplayLinkRef inDisplayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags inFlagsIn, CVOptionFlags *inFlagsOut, void *ioDisplayLinkContext);

@implementation CCVStream

- (id)init
{
if ((self = [super init]) != NULL)
	{
	movie = NULL;
    qtVisualContext = NULL;

	currentFrame = NULL;
	lock = [[NSRecursiveLock alloc] init];
	}
return(self);
}

- (void)dealloc
{
[self setMovie:NULL];
if (qtVisualContext != NULL)
	{
	CFRelease(qtVisualContext);
    qtVisualContext = NULL;
	}
if (currentFrame != NULL)
	{
	currentFrame = NULL;
	CVOpenGLTextureRelease(currentFrame); 
	}
if (displayLink)
	{
	CVDisplayLinkRelease(displayLink);
	displayLink = NULL;
	}
displayID = NULL;
[self setOpenGLContext:NULL];
//
[super dealloc];
}

#pragma mark -

- (QTMovie *)movie
{
return(movie);
}

- (void)setMovie:(QTMovie *)inMovie
{
if (movie != inMovie)
	{
	QTVisualContextRef theVisualContext = NULL;
	QTMovie *theNewMovie = NULL;	
	
	if (inMovie != NULL)
		{
		theVisualContext = [[self openGLContext] quickTimeVisualContext];
		theNewMovie = [inMovie movieWithVisualContext:theVisualContext];
		}

	// Clean up the old visual context and store the new one...
	if (qtVisualContext)
		CFRelease(qtVisualContext);
	qtVisualContext = theVisualContext;
	if (qtVisualContext != NULL)
		CFRetain(qtVisualContext);
	
	// Clean up the old movie and store the new one...
	[movie release];
	movie = [theNewMovie retain];
	
	// "Touch" the display link...
	[self displayLink];

	}
}

#pragma mark -

- (CGDirectDisplayID)displayID
{
return(displayID);
}

- (void)setDisplayID:(CGDirectDisplayID)inDisplayID
{
displayID = inDisplayID;
}

- (NSOpenGLContext *)openGLContext
{
return(openGLContext);
}

- (void)setOpenGLContext:(NSOpenGLContext *)inOpenGLContext
{
if (inOpenGLContext != openGLContext)
	{
	[openGLContext autorelease];
	openGLContext = [inOpenGLContext retain];
	}
}

- (CVDisplayLinkRef)displayLink
{
if (displayLink == NULL)
	{
	// Create display link...
	CVReturn theStatus = CVDisplayLinkCreateWithCGDisplay([self displayID], &displayLink); 
	if (theStatus != kCVReturnSuccess) [NSException raise:NSGenericException format:@"CVDisplayLinkCreateWithDisplay -- Failed with %d", theStatus];
	theStatus = CVDisplayLinkSetOutputCallback(displayLink, MyCVDisplayLinkOutputCallback, self);
	if (theStatus != kCVReturnSuccess) [NSException raise:NSGenericException format:@"CVDisplayLinkSetOutputCallback -- Failed with %d", theStatus];
	// And start it!
	theStatus = CVDisplayLinkStart(displayLink);
	}
return(displayLink);
}

- (QTVisualContextRef)qtVisualContext
{
return(qtVisualContext);
}

#pragma mark -

- (BOOL)imageAvailableForTimeStamp:(const CVTimeStamp *)inTimeStamp
{
CVOpenGLTextureRef theNewTextureRef = NULL;
if (QTVisualContextIsNewImageAvailable(qtVisualContext, inTimeStamp)) 
	{
	[lock lock];
	OSStatus theStatus = QTVisualContextCopyImageForTime([self qtVisualContext], kCFAllocatorDefault, inTimeStamp, &theNewTextureRef);
	[lock unlock];
	if (theStatus != noErr) [NSException raise:NSGenericException format:@"QTVisualContextCopyImageForTime -- Failed with %d", theStatus];

	[lock lock];
	if (currentFrame)
		{
		CVOpenGLTextureRelease(currentFrame);
		}
	currentFrame = theNewTextureRef;
	[lock unlock];
	} 
return(theNewTextureRef != NULL);
}

- (CIImage *)image
{
[lock lock];
CIImage *theImage = [CIImage imageWithCVImageBuffer:currentFrame];
[lock unlock];
return(theImage);
}

- (void)imageAvailable
{
[self willChangeValueForKey:@"image"];
[self didChangeValueForKey:@"image"];
//
[lock lock];
QTVisualContextTask([self qtVisualContext]); // TODO - is this the correct location for this API call?
[lock unlock];
}

@end

static CVReturn MyCVDisplayLinkOutputCallback(CVDisplayLinkRef inDisplayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags inFlagsIn, CVOptionFlags *inFlagsOut, void *ioDisplayLinkContext)
{
#pragma unused (inDisplayLink, inNow, inFlagsIn, inFlagsOut)

// NOTE - this is called from background thread! Buyer beware.

NSAutoreleasePool *theAutoreleasePool = [[NSAutoreleasePool alloc] init];

CCVStream *theStream = (CCVStream *)ioDisplayLinkContext;
if ([theStream imageAvailableForTimeStamp:inOutputTime])
	{
	[theStream performSelectorOnMainThread:@selector(imageAvailable) withObject:NULL waitUntilDone:NO];
	}

[theAutoreleasePool release];
return(kCVReturnSuccess);
}

#pragma mark -

@implementation CCVStream (CCVStream_ConvenienceExtensions)

- (void)setView:(NSView *)inView
{
if ([inView respondsToSelector:@selector(openGLContext)] == NO)
	[NSException raise:NSGenericException format:@"%@ does not respond to openGLContext."];
	{
	NSOpenGLContext *theOpenGLContext = [inView performSelector:@selector(openGLContext)];
	[self setOpenGLContext:theOpenGLContext];
	}

CGDirectDisplayID theDisplayID = (CGDirectDisplayID)[[[[[inView window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
[self setDisplayID:theDisplayID];
}

@end

