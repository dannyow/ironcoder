//==============================================================================
// File:      Controller.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "Controller.h"
#import "LivingWord.h"
#import "LivingWordsEngine.h"

#define kAnimationInterval (1.0 / 30.0)
#define kBirthInterval 10

@interface Controller(PrivateMethods)
- (void)animate:(NSTimer *)timer;
@end

@implementation Controller
//==============================================================================
#pragma mark -
#pragma mark || Private ||
//==============================================================================
- (void)addWords:(unsigned int)count {
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSDictionary *dict = [bundle infoDictionary];
  NSArray *words = [dict objectForKey:@"Words"];
  unsigned int wordCount = [words count];
  
  for (unsigned int i = 0; i < count; ++i) {
    unsigned int idx = random() % wordCount;
    NSString *str = [words objectAtIndex:idx];
    [engine_ addWordWithString:str];
  }
}

//==============================================================================
- (void)animate:(NSTimer *)timer {
  static unsigned stepCount = 0;
  
  [engine_ step];
  [view_ setNeedsDisplay:YES];

  if (++stepCount > kBirthInterval) {
    [self addWords:2];
    stepCount = 0;
  }
}

//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================

//==============================================================================
#pragma mark -
#pragma mark || NSObject ||
//==============================================================================
- (void)awakeFromNib {
  engine_ = [[LivingWordsEngine alloc] initWithView:view_];
  timer_ = [NSTimer scheduledTimerWithTimeInterval:kAnimationInterval target:self selector:@selector(animate:) userInfo:nil repeats:YES];

}

//==============================================================================
- (void)dealloc {
  [timer_ invalidate];
  [engine_ release];
	[super dealloc];
}

@end
