//==============================================================================
// File:      LivingWordsEngine.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// Engine driving the words
//==============================================================================
#import <Cocoa/Cocoa.h>

@class LivingWord;
@class LivingWordsView;

@interface LivingWordsEngine : NSObject {
  LivingWordsView *view_;
  NSMutableArray *words_;
  NSFont *font_;
}

//==============================================================================
// Public
//==============================================================================
- (id)initWithView:(LivingWordsView *)view;

- (LivingWordsView *)view;

- (void)setFont:(NSFont *)font;
- (NSFont *)font;

- (void)addWordWithString:(NSString *)string;
- (void)addWord:(LivingWord *)word;
- (NSArray *)words;

- (void)step;

//==============================================================================
// NSObject
//==============================================================================
- (void)dealloc;

@end
