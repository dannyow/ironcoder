//
//  AppController.h
//  Arrival
//
//  Created by Ole Zorn on 14.11.07.
//  Copyright 2007 omz:software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <PubSub/PubSub.h>
#import "LetterLayer.h"

@interface AppController : NSObject {

	IBOutlet NSWindow *window;
	IBOutlet NSView *view;
	IBOutlet NSButton *forwardButton;
	IBOutlet NSButton *backButton;
	IBOutlet NSButton *linkButton;
	IBOutlet NSButton *prefButton;
	IBOutlet NSWindow *prefWindow;
	IBOutlet NSTextField *feedTextField;
	CALayer *rootLayer;
	PSFeed *feed;
	NSTimer *feedTimer;
	NSMutableArray *feedTitles;
	NSTimer *cycleTimer;
	NSMutableArray *letterLayers;
	int textIndex;
	NSString *feedURL;
}

- (IBAction)showNextEntry:(id)sender;
- (IBAction)showPreviousEntry:(id)sender;
- (IBAction)showArticle:(id)sender;

- (IBAction)showPrefs:(id)sender;
- (IBAction)closePrefs:(id)sender;
- (IBAction)setFeedToMainFeed:(id)sender;
- (IBAction)setFeedToFriendsFeed:(id)sender;
- (IBAction)setFeedToDaringFireball:(id)sender;

- (void)setText:(NSString *)text;
- (void)setInstantText:(NSString *)text;

@end
