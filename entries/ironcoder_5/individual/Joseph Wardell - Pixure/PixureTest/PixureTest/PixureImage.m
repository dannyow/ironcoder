//
//  PixureImage.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PixureImage.h"


@implementation PixureImage


- (id)initWithImage:(NSImage*)inImage;
{
	if (self = [super init])
	{
		[self setImage:inImage];
	}
	return self;
}

- (void)dealloc
{
//	[image release];
//	[bitmapRep release];
	[bitmap release];
	[colorCache release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Accessors




- (NSBitmapImageRep*)bitmap;
{ 
	return [[bitmap retain] autorelease]; 
}


- (void)setBitmap:(NSBitmapImageRep*)inBitmap;
{
	if ([[self bitmap] isEqualTo:inBitmap])
		return;

	[inBitmap retain];
	[bitmap release];
	bitmap = inBitmap;

	[colorCache release];
	colorCache = nil;
}

- (NSMutableDictionary*)colorCache;
{
	if (nil == colorCache)
		colorCache = [[NSMutableDictionary alloc] initWithCapacity:[[self bitmap] size].width * [[self bitmap] size].height];
	return colorCache;
}


#pragma mark -
#pragma mark Accessors


- (NSImage*)image;
{
	NSImage* outImage = [[[NSImage alloc] initWithSize:[[self bitmap] size]] autorelease];
	[outImage addRepresentation:[self bitmap]];
	return outImage;
}

//{ 
//	return [[image retain] autorelease]; 
//}


- (void)setImage:(NSImage*)inImage;
{
	NSBitmapImageRep* newRep = [[NSBitmapImageRep alloc] initWithData:[inImage TIFFRepresentation]];
	[self setBitmap:newRep];
}

//{
//	if ([[self image] isEqualTo:inImage])
//		return;
//
//	[inImage retain];
//	[image release];
//	image = inImage;
//
//	[bitmapRep release];
//	bitmapRep = nil;
//	
//	[colorCache release];
//	colorCache = nil;
//}

//- (NSBitmapImageRep*)bitmapRep;
//{
//	if (nil == bitmapRep)
//		bitmapRep = [[NSBitmapImageRep alloc] initWithData:[[self image] TIFFRepresentation]];
//		
//	return bitmapRep;
//}

- (NSColor*)colorAtX:(unsigned int)x y:(unsigned int)y;
{
//	NSNumber* index = [NSNumber numberWithUnsignedInt:[[self image] size].width * y + x];

//	NSArray* index = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:x], [NSNumber numberWithUnsignedInt:y], nil];

	NSString* index = [NSString stringWithFormat:@"%d - %d", x, y];

	NSColor* outColor;
	 outColor = [[self colorCache] objectForKey:index];
	if (nil != outColor)
		return outColor;

	outColor = [[[self bitmap] colorAtX:x y:y] colorUsingColorSpaceName:NSDeviceRGBColorSpace];

	[[self colorCache] setObject:outColor forKey:index];

	return outColor;
}

- (NSSize)size;
{
	return [[self bitmap] size];
}

@end
