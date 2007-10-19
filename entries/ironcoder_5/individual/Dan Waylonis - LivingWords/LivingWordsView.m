//==============================================================================
// File:      LivingWordsView.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>

#import "LivingWord.h"
#import "LivingWordsView.h"

static GLenum glReportErrorFN(const char *fnName, const char *msg) {
	GLenum err = glGetError();
	if (GL_NO_ERROR != err)
		NSLog(@"%s (%s): %s", fnName, msg, (char *)gluErrorString(err));
	
	return(err);
}

#define glReportError(a) glReportErrorFN(__PRETTY_FUNCTION__, a)

@interface LivingWordsView(PrivateMethods)
+ (NSOpenGLPixelFormat *)defaultPixelFormat;
- (void)setupGLContext;
- (void)resizeGL;
@end

@implementation LivingWordsView
//==============================================================================
#pragma mark -
#pragma mark || Private ||
//==============================================================================
+ (NSOpenGLPixelFormat *)defaultPixelFormat {
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFAWindow,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		(NSOpenGLPixelFormatAttribute)nil
	};
	
	NSOpenGLPixelFormat	*fmt = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
	
	return fmt;
}

//==============================================================================
- (void)setupGLContext {
	NSOpenGLPixelFormat	*fmt = [[self class] defaultPixelFormat];
  
	context_ = [[NSOpenGLContext alloc] initWithFormat:fmt shareContext:nil];
	[context_ setView:self];
	[context_ makeCurrentContext];
	
	glShadeModel(GL_SMOOTH);
  glEnable(GL_LINE_SMOOTH);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
	// Enable 2D, rectangular (non-power of 2) texture
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
  
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  
	// Use VBL for sync
	long swapInt = 0;
	[context_ setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

//==============================================================================
- (void)resizeGL {
	NSRect	bounds = [self bounds];
  
	// Switch to our context
	[context_ makeCurrentContext];
  
	glViewport(0, 0, NSWidth(bounds), NSHeight(bounds));
  glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
  glOrtho(0, NSWidth(bounds), 0, NSHeight(bounds), -1, 1);
	glReportError("after ortho");
	glMatrixMode(GL_MODELVIEW);
  
	glClearColor(0, 0, 0, 1); 
	glClear(GL_COLOR_BUFFER_BIT);
	
	[context_ update];
}

//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================
- (NSOpenGLContext *)openGLContext {
  return context_;
}

//==============================================================================
- (void)setEngine:(LivingWordsEngine *)engine {
  engine_ = [engine retain];
}

//==============================================================================
- (LivingWordsEngine *)engine {
  return engine_;
}

//==============================================================================
#pragma mark -
#pragma mark || NSView ||
//==============================================================================
- (void)lockFocus {
	if (! context_)	{
		[self setupGLContext];
		[self resizeGL];
	}
  
	[super lockFocus];
	[context_ makeCurrentContext];
}

//==============================================================================
- (void)setFrameSize:(NSSize)size {
	[super setFrameSize:size];
	[self resizeGL];
}

//==============================================================================
- (void)drawRect:(NSRect)rect {
  NSArray *words = [engine_ words];
  int count = [words count];
  
  glClear(GL_COLOR_BUFFER_BIT);  
  
  for (int i = count - 1; i >= 0; --i) {
    LivingWord *word = [words objectAtIndex:i];
    [word draw];
  }
  
  
  [context_ flushBuffer];
}

//==============================================================================
- (BOOL)isOpaque {
  return YES;
}

//==============================================================================
#pragma mark -
#pragma mark || NSObject ||
//==============================================================================
- (void)dealloc {
  [engine_ release];
  [context_ setView:nil];
  [context_ release];
	[super dealloc];
}

@end
