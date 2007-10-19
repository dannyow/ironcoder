//==============================================================================
// File:      Controller.h
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// Controller for application
//==============================================================================
#import <Cocoa/Cocoa.h>

@class LivingWordsEngine;
@class LivingWordsView;

@interface Controller : NSObject {
  IBOutlet LivingWordsView *view_;
  
  LivingWordsEngine *engine_;
  NSTimer *timer_;
}

//==============================================================================
// Public
//==============================================================================

//==============================================================================
// NSObject
//==============================================================================
- (void)awakeFromNib;
- (void)dealloc;

@end
