//
//  CrepuscularLife_GLView.m
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CrepuscularLife_GLView.h"

static NSOpenGLPixelFormatAttribute formatAttributes[] = 
{
	NSOpenGLPFAAccelerated,
	NSOpenGLPFADoubleBuffer,
	NSOpenGLPFAColorSize, 32,
	NSOpenGLPFADepthSize, 16,
	NSOpenGLPFAMinimumPolicy,
	NSOpenGLPFAClosestPolicy,
	0
};	

@implementation CREPLIFE_GLView

+ (NSOpenGLPixelFormat*) defaultPixelFormat
{
	NSOpenGLPixelFormat *format;

	format = [[[NSOpenGLPixelFormat alloc] 
					initWithAttributes: formatAttributes] autorelease];
					
	return format;
}

- (BOOL) isOpaque
{
	return NO;
}

@end
