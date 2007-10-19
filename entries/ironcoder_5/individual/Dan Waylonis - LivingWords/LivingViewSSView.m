//==============================================================================
// File:      LivingViewSSView.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "LivingViewSSView.h"
#import "LivingWordsView.h"
#import "LivingWordsEngine.h"

#define kBirthInterval 10

@interface LivingViewSSView(PrivateMethods)
- (void)addWords:(unsigned int)count;
@end

@implementation LivingViewSSView
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
#pragma mark -
#pragma mark || Public ||
//==============================================================================
- (void)startAnimation {
  counter_ = 0;
}

- (void)animateOneFrame {
  
  [engine_ step];
  ++counter_;
  
  if (counter_ > kBirthInterval) {
    [self addWords:2];
    counter_ = 0;
  }
}

//==============================================================================
#pragma mark -
#pragma mark || NSView ||
//==============================================================================
- (id)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
    NSRect b = NSMakeRect(0, 0, NSWidth(frame), NSHeight(frame));
    wordsView_ = [[LivingWordsView alloc] initWithFrame:b];
    [self addSubview:wordsView_];
    [wordsView_ setBounds:b];
    [wordsView_ setFrame:b];
    [self setAnimationTimeInterval:1/30.0];
    engine_ = [[LivingWordsEngine alloc] initWithView:wordsView_];
    NSLog(@"Words view: %@", wordsView_);
    NSLog(@"Engine: %@", engine_);
	}

	return self;
}

//==============================================================================
- (void)drawRect:(NSRect)rect {
  [[NSColor redColor] set];
  NSRectFill(rect);
}

//==============================================================================
#pragma mark -
#pragma mark || NSObject ||
//==============================================================================
- (void)awakeFromNib {
}

//==============================================================================
- (void)dealloc {
  [wordsView_ removeFromSuperview];
  [engine_ release];
	[super dealloc];
}

@end
