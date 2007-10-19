//
//  TwitterBugView.h
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright (c) 2007 Colin Gislason. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "TwitterQueue.h"
#import "TwitterMessage.h"

@interface TwitterBugView : ScreenSaverView 
{
	TwitterQueue *messageQueue;
	NSMutableDictionary *stringAttributes;
	TwitterMessage *currentMessage;
	NSPoint messagePosition;
	
	// Options
	int messageDelay;
	NSSize messageSize;
	NSString *messageFont;
	int fontSize;
	BOOL showFriendsTimeline;
	NSString *userName;
	NSString *password;
	NSColor *fontColor;
	
	// Preferences
	IBOutlet id messageDelayOption;
	IBOutlet id messageSizeWidthOption;
	IBOutlet id messageSizeHeightOption;
	IBOutlet id messageFontOption;
	IBOutlet id fontSizeOption;
	IBOutlet id fontColorOption;
	IBOutlet id showFriendsTimelineOption;
	IBOutlet id userNameOption;
	IBOutlet id passwordOption;
	
	// Internal attributes
	float frameRate;
	int framesPassed;
	int frameDelay;
	BOOL isPreviewMode;
	
	// Preferences sheet
	IBOutlet id configSheet;
}
- (void)drawMessage:(TwitterMessage*)drawMessage withAlpha:(float)alpha;
- (NSPoint)randomPoint;
- (NSRect)textRectWithMargin:(float)margin;
- (void)initDefaults;

- (IBAction)okClick:(id)sender;
- (IBAction)cancelClick:(id)sender;

@end
