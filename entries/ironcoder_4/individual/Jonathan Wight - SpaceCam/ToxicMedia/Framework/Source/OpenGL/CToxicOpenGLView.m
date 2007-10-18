//
//  CToxicOpenGLView.m
//  CustomOpenGLView
//
//  Created by Jonathan Wight on 7/30/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CToxicOpenGLView.h"

#import <OpenGL/gl.h>
#import "CToxicOpenGLViewHelper.h"

@implementation CToxicOpenGLView

- (void)dealloc
{
[helper autorelease];
helper = NULL;
//
[super dealloc];
}

#pragma mark -

- (id)initWithCoder:(NSCoder *)inCoder 
{
if ((self = [super initWithCoder:inCoder]) != NULL)
	{
	[helper autorelease];
	helper = [[inCoder decodeObjectForKey:@"helper"] retain];
	[helper setView:self];
    }
return(self);
}

- (void)encodeWithCoder:(NSCoder *)inCoder 
{
[super encodeWithCoder:inCoder];
//
[inCoder encodeObject:helper forKey:@"helper"];
}

#pragma mark -

- (void)lockFocus
{
[super lockFocus];
[[self helper] lockFocus];
}

- (void)unlockFocus
{
[[self helper] unlockFocus];
[super unlockFocus];
}

#pragma mark -

- (CToxicOpenGLViewHelper *)helper
{
if (helper == NULL)
	{
	helper = [[CToxicOpenGLViewHelper alloc] init];
	[helper setView:self];
	}
return(helper); 
}

#pragma mark -

- (void)update
{
[[self helper] update];
}

#pragma mark -

- (void)drawRect:(NSRect)inRect
{
#pragma unused (inRect)
if (NSIsEmptyRect([self visibleRect]))  
	{
	glViewport(0, 0, 1, 1);
	}
else
	{
	NSRect theFrame = [self frame];
	glViewport(0, 0, theFrame.size.width, theFrame.size.height);
	}
glMatrixMode(GL_MODELVIEW);
glLoadIdentity();
glMatrixMode(GL_PROJECTION);
glLoadIdentity();
NSRect theBounds = [self bounds];
glOrtho(NSMinX(theBounds), NSMaxX(theBounds), NSMinY(theBounds), NSMaxY(theBounds), -1.0f, 1.0f);
glClearColor(0.0f, 0.2f, 0.0f, 0.0f);
glClear(GL_COLOR_BUFFER_BIT);

glFlush();
}

@end
