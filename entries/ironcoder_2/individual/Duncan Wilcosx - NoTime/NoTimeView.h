//
//  NoTimeView.h
//  NoTime
//
//  Created by Duncan Wilcox on 7/22/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NoTimeGame;
@class NoTimeLayer;
@class NoTimeGuy;
@class NoTimeSprite;

@interface NoTimeView : NSView
{
	NoTimeGame *game;
	NoTimeLayer *backgroundPainter;
	NoTimeLayer *foregroundPainter;
	NoTimeGuy *guy;
	NoTimeSprite *bonus;
	NoTimeSprite *loot;
	NoTimeSprite *ircmonster;
	NoTimeSprite *newsmonster;
	NSTimer *refreshTimer;
}

@end
