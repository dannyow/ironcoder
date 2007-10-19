//
//  MCTwitter.h
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/30/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	MCTwitter_publicTimeline,  //timeline of everyone's updates
	MCTwitter_friendsTimeline, //timeline of friend's updates
	MCTwitter_friends,  //friends list w/ their last update
	MCTwitter_followers //followers list w/ their last update
} TwitterRemoteCall;

@interface MCTwitter : NSObject {
	NSString *_login;
	NSString *_password;
	NSURL *_url;
	NSMutableData *_receivedData;
	NSMutableArray *_returnArray;
	NSMutableDictionary *_currentUser;
	NSMutableDictionary *_currentStatus;
	NSString *_currentKey;
	id _delegate;
}

- (id)initWithLogin:(NSString *)login password:(NSString *)password forCall:(TwitterRemoteCall) call;
- (void)request;
- (void)setDelegate:(id)delegate;
- (void)returnErrorTwitter;

@end
