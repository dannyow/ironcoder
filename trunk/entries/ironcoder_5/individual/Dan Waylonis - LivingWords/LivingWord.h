//==============================================================================
// File:      LivingWord.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// A word/string that is alive
//==============================================================================
#import <Cocoa/Cocoa.h>

#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>

@class LifeMachine;
@class LivingWordsEngine;
@class LivingWordsView;

@interface LivingWord : NSObject {
  NSBitmapImageRep *bitmap_;
  unsigned short *shadowBitmap_;
  unsigned int width_;
  unsigned int height_;
  LivingWordsEngine *engine_;
  LivingWordsView *view_;
  NSOpenGLContext *context_;
  float alpha_;
  NSPoint positionDelta_;
  NSColor *color_;
  NSRect frame_;
  unsigned int stepCount_;
  LifeMachine *machine_;
  GLuint textureID_;
  GLuint pathTextureID_;
  CGLContextObj	textureContext_;
}

//==============================================================================
// Public
//==============================================================================
- (id)initWithEngine:(LivingWordsEngine *)engine;

- (void)setPath:(NSBezierPath *)path;

- (void)setAlpha:(float)alpha;
- (float)alpha;

- (void)setFrame:(NSRect)frame;
- (void)setFrameOrigin:(NSPoint)origin;
- (NSRect)frame;

- (void)setPositionDelta:(NSPoint)delta;
- (NSPoint)positionDelta;

- (void)setColor:(NSColor *)color;
- (NSColor *)color;

- (void)step;
- (unsigned int)stepCount;

- (void)draw;

//==============================================================================
// NSObject
//==============================================================================
- (void)dealloc;

@end
