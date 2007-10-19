//
//  TwitterView.h
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/31/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TwitterView : NSView {

	NSMutableArray *_drawingObjects;
	NSTimer *_animator;
}

- (void)animate;
- (void)animate:(id)sender;
- (void)fadeAll:(id)sender;

- (void)receivedResponse:(NSArray *)response;

@end
