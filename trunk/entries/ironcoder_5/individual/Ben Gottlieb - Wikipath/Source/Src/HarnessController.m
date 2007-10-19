//
//  HarnessController.m
//  TestScreenSaver
//
//  Created by Ben Gottlieb on 3/31/07.
//  Copyright 2007 Stand Alone, Inc.. All rights reserved.
//

#import "HarnessController.h"
#import "SaverView.h"

@implementation HarnessController

- (void) awakeFromNib {
	NSView							*parent = [window contentView];
	NSRect							bounds = [parent bounds];
	
	bounds.origin.y += 45.0;
	bounds.size.height -= 45.0;
	
	view = [[WikiPathScreenSaver_SaverView alloc] initWithFrame: bounds isPreview: YES];
	[view setInTestHarness: YES];
	[parent addSubview: view];
	
	NSTimeInterval					interval = [view animationTimeInterval];
	
	
	timer = [[NSTimer scheduledTimerWithTimeInterval: interval target: self selector: @selector(timerFired:) userInfo: nil repeats: YES] retain];
	[view startAnimation];
	[view setNeedsDisplay: YES];
}

- (void) timerFired: (NSTimer *) timer {
	[view animateOneFrame];
}

- (IBAction) configure: (id) sender {
	[NSApp beginSheet: [view configureSheet] modalForWindow: window modalDelegate: view didEndSelector: nil contextInfo: nil];
	

//	[[view configureSheet] makeKeyAndOrderFront: self];
}

@end
