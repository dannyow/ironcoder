//
//  TwitterLifeView.h
//  TwitterLife
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright (c) 2007, MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
@class TwitterView;
@class ConfigPanel;

@interface TwitterLifeView : ScreenSaverView 
{
	TwitterView *_tView;
	NSTimer *_timer;
	ConfigPanel *_panel;
}

- (void)updateData;

@end
