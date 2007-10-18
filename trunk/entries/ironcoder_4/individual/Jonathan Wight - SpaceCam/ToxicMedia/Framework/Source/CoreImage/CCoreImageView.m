//
//  CCoreImageView.m
//  MotionDetector
//
//  Created by Jonathan Wight on 7/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CCoreImageView.h"

#import "Geometry.h"
#import <QuartzCore/QuartzCore.h>
#import "CToxicOpenGLViewHelper.h"

@interface CCoreImageView (CCoreImageView_Private)
- (void)setup;
- (CIFilter *)flipHorizontalFilter;
- (CIFilter *)cropFilter;
@end

@implementation CCoreImageView

+ (void)initialize
{
[self exposeBinding:@"image"];
[self exposeBinding:@"scaling"];
[self exposeBinding:@"alignment"];
[self exposeBinding:@"flipHorizontal"];
[self exposeBinding:@"crop"];
[self exposeBinding:@"cropRect"];
}

- (id)initWithFrame:(NSRect)inFrame
{
if ((self = [super initWithFrame:inFrame]) != NULL)
	{
	[self setup];
	}
return(self);
}

- (id)initWithCoder:(NSCoder *)inDecoder
{
if ((self = [super initWithCoder:inDecoder]) != NULL)
	{
	[self setup];
	//
	if ([inDecoder containsValueForKey:@"scaling"])
		[self setScaling:[inDecoder decodeIntForKey:@"scaling"]];
	if ([inDecoder containsValueForKey:@"alignment"])
		[self setAlignment:[inDecoder decodeIntForKey:@"alignment"]];
	if ([inDecoder containsValueForKey:@"flipHorizontal"])
		[self setFlipHorizontal:[inDecoder decodeBoolForKey:@"flipHorizontal"]];
	if ([inDecoder containsValueForKey:@"crop"])
		[self setCrop:[inDecoder decodeBoolForKey:@"crop"]];
	}
return(self);
}

- (void)dealloc
{
[image autorelease];
image = NULL;

[flipHorizontalFilter autorelease];
flipHorizontalFilter = NULL;

[cropFilter autorelease];
cropFilter = NULL;

[super dealloc];
}

#pragma mark -

- (void)encodeWithCoder:(NSCoder *)inCoder
{
[super encodeWithCoder:inCoder];
//
[inCoder encodeInt:[self scaling] forKey:@"scaling"];
[inCoder encodeInt:[self alignment] forKey:@"alignment"];
[inCoder encodeBool:[self flipHorizontal] forKey:@"flipHorizontal"];
[inCoder encodeBool:[self crop] forKey:@"crop"];
[inCoder encodeRect:[self cropRect] forKey:@"cropRect"];
}

#pragma mark -

- (void)viewWillMoveToSuperview:(NSView *)newSuperview;
{
[super viewWillMoveToSuperview:newSuperview];

if ([newSuperview respondsToSelector:@selector(setCopiesOnScroll:)])
	{
	[(id)newSuperview setCopiesOnScroll:NO];
	}
}

- (void)setFrameSize:(NSSize)inNewSize
{
needsReshape = YES;
[super setFrameSize:inNewSize];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize;
{
[super resizeWithOldSuperviewSize:oldSize];
needsReshape = YES;
}

- (void)lockFocus
{
[super lockFocus];
if ([self useOpenGL])
	[[self openGLHelper] lockFocus];
}

- (void)unlockFocus
{
if ([self useOpenGL])
	[[self openGLHelper] unlockFocus];
[super unlockFocus];
}

- (void)drawRect:(NSRect)inRect
{
[self beginDraw];
[self drawImage:inRect];
[self endDraw];
}

#pragma mark -

- (CIImage *)image
{
return(image);
}

- (void)setImage:(CIImage *)inImage
{
if (image != inImage)
	{
	[image autorelease];
	image = [inImage retain];
	//
	[self setNeedsDisplay:YES];
	}
}

#pragma mark -

- (NSImageScaling)scaling
{
return(scaling);
}
- (void)setScaling:(NSImageScaling)inScaling
{
if (scaling != inScaling)
	{
	scaling = inScaling;
	[self setNeedsDisplay:YES];
	}
}

- (NSImageAlignment)alignment
{
return(alignment);
}

- (void)setAlignment:(NSImageAlignment)inAlignment
{
if (alignment != inAlignment)
	{
	alignment = inAlignment;
	[self setNeedsDisplay:YES];
	}
}

- (BOOL)flipHorizontal
{
return(flipHorizontal);
}

- (void)setFlipHorizontal:(BOOL)flag
{
if (flipHorizontal != flag)
	{
	flipHorizontal = flag;
	[self setNeedsDisplay:YES];
	}
}

- (BOOL)crop
{
return(crop);
}

- (void)setCrop:(BOOL)inCrop
{
if (crop != inCrop)
	{
	crop = inCrop;
	[self setNeedsDisplay:YES];
	}
}

- (NSRect)cropRect
{
return(cropRect);
}

- (void)setCropRect:(NSRect)inCropRect
{
cropRect = inCropRect;

[cropFilter autorelease];
cropFilter = NULL;

if ([self crop] == YES)
	[self setNeedsDisplay:YES];
}

#pragma mark -

- (BOOL)useOpenGL
{
return(useOpenGL);
}

- (void)setUseOpenGL:(BOOL)inUseOpenGL
{
useOpenGL = inUseOpenGL;
}

- (CToxicOpenGLViewHelper *)openGLHelper
{
if (openGLHelper == NULL)
	{
	openGLHelper = [[CToxicOpenGLViewHelper alloc] init];
	[openGLHelper setView:self];
	}
return(openGLHelper);
}

- (CIContext *)ciContext
{
CIContext *theCIContext = NULL;
if ([self useOpenGL] == NO)
	{
	CGContextRef theCGContext = [[NSGraphicsContext currentContext] graphicsPort];

	NSDictionary *theContextOptions = NULL;
	if (NO)
		{
		theContextOptions = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], kCIContextUseSoftwareRenderer,
			NULL];
		}
	theCIContext = [CIContext contextWithCGContext:theCGContext options:theContextOptions];
	}
else
	{
	// Create the CoreImage context...
	theCIContext = [[self openGLHelper] coreImageContext];
	}
return(theCIContext);
}

#pragma mark -

- (CIImage *)imageToDraw;
{
CIImage *theImageToDraw = [self image];
return(theImageToDraw);
}

#pragma mark -

- (void)beginDraw
{
if ([self useOpenGL])
	{
	NSRect frame = [self frame];
	NSRect bounds = [self bounds];

	[[[self openGLHelper] openGLContext] makeCurrentContext]; 
	if (needsReshape == YES) 
		{
		needsReshape = NO;
		[[self openGLHelper] update]; 
		if (NSIsEmptyRect([self visibleRect]))  
			{
			glViewport(0, 0, 1, 1);
			}
		else
			{
			glViewport(0, 0, frame.size.width ,frame.size.height);
			}
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(NSMinX(bounds), NSMaxX(bounds), NSMinY(bounds), NSMaxY(bounds), -1.0, 1.0);
		}
	glClearColor(0.5, 0.5, 0.5, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	}
}

- (void)drawImage:(NSRect)inRect
{
CIImage *theImage = [self imageToDraw];
if (theImage != NULL)
	{
	if ([self flipHorizontal])
		{
		CIFilter *theFilter = [self flipHorizontalFilter];
		NSAffineTransform *theTransform = [NSAffineTransform transform];
		[theTransform scaleXBy:-1.0f yBy:1.0f];
		[theTransform translateXBy:0.0f - [theImage extent].size.width yBy:0.0f];
		[theFilter setValue:theTransform forKey:@"inputTransform"];		
		[theFilter setValue:theImage forKey:@"inputImage"];
		theImage = [theFilter valueForKey:@"outputImage"];
		}

	if ([self crop])
		{
		CIFilter *theFilter = [self cropFilter];
		[theFilter setValue:theImage forKey:@"inputImage"];
		theImage = [theFilter valueForKey:@"outputImage"];
		}

	NSRect theImageRect;
	NSRect theDestinationRect;
	
	if ([self scaling] == NSScaleNone)
		{
		theImageRect = NSRectFromCGRect([theImage extent]);
		theImageRect = NSOffsetRect(theImageRect, inRect.origin.x, inRect.origin.y);
		theImageRect.size = [self frame].size;
		
		theDestinationRect = [self bounds];
		}
	else
		{
		theImageRect = NSRectFromCGRect([theImage extent]);
		theDestinationRect = ScaleImageRectToRect(theImageRect, [self bounds], scaling, alignment);
		}
	[[self ciContext] drawImage:theImage inRect:CGRectFromNSRect(theDestinationRect) fromRect:CGRectFromNSRect(theImageRect)];
	}
}

- (void)endDraw
{
if ([self useOpenGL])
	{
	glFlush();
	}
}

@end

#pragma mark -

@implementation CCoreImageView (CCoreImageView_Private)

- (void)setup
{
[self setScaling:NSScaleProportionally];
[self setAlignment:NSImageAlignCenter];
[self setFlipHorizontal:NO];
flipHorizontalFilter = NULL;
[self setCrop:NO];
[self setCropRect:NSMakeRect(0.0f, 0.0f, 640.0f, 480.0f)];

useOpenGL = YES;
needsReshape = YES;
}

- (CIFilter *)flipHorizontalFilter
{
if (flipHorizontalFilter == NULL)
	{
	NSAffineTransform *theTransform = [NSAffineTransform transform];
	[theTransform scaleXBy:-1.0f yBy:1.0f];
	[theTransform translateXBy:[[self imageToDraw] extent].size.width yBy:0.0f];
	CIFilter *theFilter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:@"inputTransform", theTransform, NULL];
	
	flipHorizontalFilter = [theFilter retain];
	}
return(flipHorizontalFilter);
}

- (CIFilter *)cropFilter
{
if (cropFilter == NULL)
	{
	CGRect theRect = CGRectFromNSRect([self cropRect]);
	CIVector *theCropVector = [CIVector vectorWithX:theRect.origin.x Y:theRect.origin.y Z:theRect.size.width W:theRect.size.height];
	CIFilter *theFilter = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputRectangle", theCropVector, NULL];
	cropFilter = [theFilter retain];
	}
return(cropFilter);
}

@end
