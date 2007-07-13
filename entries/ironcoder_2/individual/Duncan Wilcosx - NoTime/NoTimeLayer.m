//
//  NoTimeLayer.m
//  NoTime
//
//  Created by Duncan Wilcox on 7/23/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import "NoTimeLayer.h"

@implementation NoTimeLayer

- (id)initWithFile:(NSString *)name
{
	[self loadFile:name];
	return self;
}

- (void)dealloc
{
	if(layer)
		CGLayerRelease(layer);
	[super dealloc];
}

- (void)loadFile:(NSString *)file
{
	NSData *pngdata = [[[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file]] autorelease];
	if(pngdata)
	{
		CGImageSourceRef png = CGImageSourceCreateWithData((CFDataRef)pngdata, 0);
		if(png)
		{
			CGImageRef im = CGImageSourceCreateImageAtIndex(png, 0, 0);
			CFRelease(png);
			[self setImage:im];
			CGImageRelease(im);
		}
	}
}

- (void)setImage:(CGImageRef)image
{
	if(layer)
		CGLayerRelease(layer);
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	layer = CGLayerCreateWithContext(ctx, CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image)), 0);
	CGContextRef layerctx = CGLayerGetContext(layer);
	CGContextDrawImage(layerctx, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
}

- (void)setSize:(CGSize)newSize
{
	size = newSize;
}

- (CGSize)size
{
	if(size.width == 0 && size.height == 0)
		return CGLayerGetSize(layer);
	return size;
}

- (void)drawAtPoint:(CGPoint)p
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect r;
	r.origin = p;
	r.size = [self size];
	CGContextDrawLayerInRect(ctx, r, layer);
}

- (void)tileInRect:(CGRect)r atOffset:(CGPoint)offs
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGSize s = [self size];
	unsigned x;
	unsigned y;
	for(x = 0; x < (unsigned)(r.size.width / s.width + .5); x++)
		for(y = 0; y < (unsigned)(r.size.height / s.height + .5); y++)
		{
			CGRect pos = CGRectMake(r.origin.x + x * s.width + offs.x, r.origin.y + y * s.height + offs.y, s.width, s.height);
			CGContextDrawLayerInRect(ctx, CGRectIntegral(pos), layer);
		}
}

@end
