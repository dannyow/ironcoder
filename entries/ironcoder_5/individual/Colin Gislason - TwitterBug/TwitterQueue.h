//
//  TwitterQueue.h
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright 2007 Colin Gislason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterMessage.h"

@interface TwitterQueue : NSObject {
	NSMutableArray *twitterMessages;
	
	BOOL showFriendsTimeline;
	NSString *userName;
	NSString *password;
}

- (id)initAndFill;
- (id)initAndFillShowFriendsTimeline:(BOOL)showFriends userName:(NSString*)user password:(NSString*)pass;
- (TwitterMessage*)nextMessage;
- (void)removeAllObjects;
- (void)addMessage:(TwitterMessage*)newMessage;
- (void)refillQueue;
- (int)count;

- (void)setShowFriendsTimeline:(BOOL)showFriends;
- (BOOL)showFriendsTimeline;
- (void)setUserName:(NSString*)user;
- (NSString*)userName;
- (void)setPassword:(NSString*)password;
- (NSString*)password;

@end
