//
//  Controller.h
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/31/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com . All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MCTwitter;
@class TwitterView;

@interface Controller : NSObject {

	IBOutlet NSPopUpButton *_selector;
	IBOutlet TwitterView *_view;

}

- (void)getTwitterInfo:(id)sender;

@end
