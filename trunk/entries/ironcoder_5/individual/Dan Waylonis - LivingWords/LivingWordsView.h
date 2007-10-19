//==============================================================================
// File:      LivingWordsView.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// Open GL view for drawing
//==============================================================================
#import <Cocoa/Cocoa.h>

@class LivingWordsEngine;

@interface LivingWordsView : NSView {
  NSOpenGLContext *context_;
  LivingWordsEngine *engine_;
}

//==============================================================================
// Public
//==============================================================================
- (NSOpenGLContext *)openGLContext;

- (void)setEngine:(LivingWordsEngine *)engine;
- (LivingWordsEngine *)engine;

//==============================================================================
// NSView
//==============================================================================
- (void)lockFocus;
- (void)setFrameSize:(NSSize)size;
- (void)drawRect:(NSRect)rect;
- (BOOL)isOpaque;

//==============================================================================
// NSObject
//==============================================================================
- (void)dealloc;

@end
