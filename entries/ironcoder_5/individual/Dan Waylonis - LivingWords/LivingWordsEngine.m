//==============================================================================
// File:      LivingWordsEngine.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "LivingWord.h"
#import "LivingWordsEngine.h"
#import "LivingWordsView.h"
#import "NSBezierPath+String.h"
#import "NSColor+Random.h"
#import "RectUtilities.h"
#import "Utilities.h"

#define kMaxWords 10
#define kDeathCount 50

@interface LivingWordsEngine(PrivateMethods)
@end

@implementation LivingWordsEngine
//==============================================================================
#pragma mark -
#pragma mark || Private ||
//==============================================================================

//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================
- (id)initWithView:(LivingWordsView *)view {
  if (self = [super init]) {
    view_ = view;
    [view_ setEngine:self];
    words_ = [[NSMutableArray alloc] init];
    [self setFont:[NSFont fontWithName:@"Times-Roman" size:120]];
  }
  
  return self;
}

//==============================================================================
- (LivingWordsView *)view {
  return view_;
}

//==============================================================================
- (void)setFont:(NSFont *)font {
  [font_ autorelease];
  font_ = [font retain];
}

//==============================================================================
- (NSFont *)font {
  return font_;
}

//==============================================================================
- (void)addWordWithString:(NSString *)string {
  if ([words_ count] > kMaxWords)
    return;
  
  LivingWord *word = [[LivingWord alloc] initWithEngine:self];
  NSBezierPath *path = [NSBezierPath bezierPath];

  [path appendString:string font:font_];
  [word setPath:path];
  
  NSPoint origin = RandomPointForSizeWithinRect([path bounds].size,
                                                [view_ bounds]);
  [word setFrameOrigin:origin];
  [word setColor:[NSColor randomOpaqueColor]];
  [word setPositionDelta:NSMakePoint(RandomFloatBetween(-2, 2),
                                     RandomFloatBetween(-2, 2))];
  [self addWord:word];
  [word release];
}

//==============================================================================
- (void)addWord:(LivingWord *)word {
  [words_ addObject:word];
}

//==============================================================================
- (NSArray *)words {
  return words_;
}

//==============================================================================
- (void)step {
  unsigned int i, count = [words_ count];
  NSMutableArray *death = [NSMutableArray array];
  
  for (i = 0; i < count; ++i) {
    LivingWord *word = [words_ objectAtIndex:i];
    
    [word step];
    if ([word stepCount] > kDeathCount)
      [death addObject:word];
  }
  
  [words_ removeObjectsInArray:death];
}

//==============================================================================
#pragma mark -
#pragma mark || NSObject ||
//==============================================================================
- (void)dealloc {
  [words_ release];
	[super dealloc];
}

@end
