//
//  ALImageView.m
//  BlurredLife
//
//  Created by Adam Leonard on 3/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//Most of this code is from http://www.cocoadev.com/index.pl?FakeImageView by Mike Trent
//It basically reimplements the proportional scaling option of NSImageView to be better and stuff :)
//I added code to draw a white border around the image

#import "ALImageView.h"

@implementation ALImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        _scaling = NSScaleProportionally;
		[self setShouldShowBorder:NO];
    }
	
    return self;
}

- (void)dealloc
{
    [_image release];
	[scaledImage release];
    [super dealloc];
}

- (void) setImage:(NSImage*)image
{
    [self setImageWithoutNeedingDisplay:image];
    [self setNeedsDisplay:YES];
}
- (void)setImageWithoutNeedingDisplay:(NSImage *)image;
{
	if (_image) {
        [_image autorelease];
        _image = nil;
    }
	
    _image = [image retain];
    [_image setScalesWhenResized:YES];
}

- (NSImage*)image
{
    return _image;
}

- (void)setImageScaling:(NSImageScaling)newScaling
{
    _scaling = newScaling;
    [self setNeedsDisplay:YES];
}

- (NSImageScaling)imageScaling
{
    return _scaling;
}

- (void)drawRect:(NSRect)rect
{	
	float rx, ry, r;
	NSPoint borderOrigin, imageOrigin;
	NSRect borderBounds = [self frame];
	NSSize borderSize = NSMakeSize((borderBounds.size.width - 6),(borderBounds.size.height - 6));
	NSSize maxImageSize = NSMakeSize((borderSize.width - 12),(borderSize.height - 12));
	if (_image) 
	{
		
		if(scaledImage)
		{
			[scaledImage release];
		}
		scaledImage = [_image copy];
		NSSize size = [scaledImage size];
		
		
		switch (_scaling) 
		{
			case NSScaleProportionally:
				rx = maxImageSize.width / size.width;
				ry = maxImageSize.height / size.height;
				r = rx < ry ? rx : ry;
				size.width *= r;
				size.height *= r;
				[scaledImage setSize:size];
				break;
			case NSScaleToFit:
				size = maxImageSize;
				[scaledImage setSize:size];
				break;
			case NSScaleNone:
				break;
			default:
				;	
		}
		
		borderOrigin.x = ((borderSize.width - size.width) / 2)-6;
		borderOrigin.y = ((borderSize.height - size.height) / 2)-6;
		
		imageOrigin.x = ((maxImageSize.width - size.width) / 2)+6;
		imageOrigin.y = ((maxImageSize.height - size.height) / 2)+6;
		
		[self setScaledImageRect:NSMakeRect(borderOrigin.x,borderOrigin.y,(size.width + 12),(size.height + 12))];
		
		if([self shouldShowBorder])
		{
			//draw a white frame around the image
			[[NSGraphicsContext currentContext]saveGraphicsState];
			[[NSColor whiteColor]set];
			NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:[self scaledImageRect]];
			[boxPath fill];
			[[NSGraphicsContext currentContext]restoreGraphicsState];
		}
		[scaledImage dissolveToPoint:imageOrigin fraction:1.0];	

    }
}


- (NSRect)scaledImageRect
{
    return scaledImageRect;
}
- (void)setScaledImageRect:(NSRect)aScaledImageRect
{
    scaledImageRect = aScaledImageRect;
}


- (NSImage *)scaledImage
{
    return scaledImage; 
}
- (void)setScaledImage:(NSImage *)aScaledImage
{
    [aScaledImage retain];
    [scaledImage release];
    scaledImage = aScaledImage;
}


- (BOOL)shouldShowBorder
{
    return shouldShowBorder;
}
- (void)setShouldShowBorder:(BOOL)flag
{
    shouldShowBorder = flag;
	[self setNeedsDisplay:YES];
}





@end
