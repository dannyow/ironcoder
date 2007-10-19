//==============================================================================
// File:      LivingViewSSView.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// ScreenSaver view
//==============================================================================
#import <Cocoa/Cocoa.h>

#import <ScreenSaver/ScreenSaver.h>

@class LivingWordsView;
@class LivingWordsEngine;

@interface LivingViewSSView : ScreenSaverView {
  LivingWordsView *wordsView_;
  LivingWordsEngine *engine_;
  unsigned int counter_;
}

//==============================================================================
// Public
//==============================================================================

//==============================================================================
// NSView
//==============================================================================
- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)rect;

//==============================================================================
// NSObject
//==============================================================================
- (void)awakeFromNib;
- (void)dealloc;

@end
