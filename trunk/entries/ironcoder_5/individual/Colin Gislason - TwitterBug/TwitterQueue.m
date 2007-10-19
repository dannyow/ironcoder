//
//  TwitterQueue.m
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright 2007 Colin Gislason. All rights reserved.
//

#import "TwitterQueue.h"

@implementation TwitterQueue

static NSString * const TwitterPublicTimelineURL = @"http://twitter.com/statuses/public_timeline.xml";
static NSString * const TwitterFriendsTimelineURL = @"twitter.com/statuses/friends_timeline.xml";

- (id)init
{
	self = [super init];
	if(self)
	{
		twitterMessages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initAndFill
{
	self = [super init];
	if(self)
	{
		twitterMessages = [[NSMutableArray alloc] init];
		
		[self refillQueue];
	}
	return self;
}

- (id)initAndFillShowFriendsTimeline:(BOOL)showFriends userName:(NSString*)user password:(NSString*)pass
{
	self = [super init];
	if(self)
	{
		twitterMessages = [[NSMutableArray alloc] init];
		
		[self setShowFriendsTimeline:showFriends];
		[self setUserName:user];
		[self setPassword:pass];
		
		[self refillQueue];
	}
	return self;
}

- (void) dealloc
{
	NSLog(@"dealloc in TwitterQueue");
	[super dealloc];
	[twitterMessages release];
	[userName release];
	[password release];
}

- (int)count
{
	return [twitterMessages count];
}

// Queue operations

- (TwitterMessage*)nextMessage
{
	TwitterMessage *nextMessage = nil;
	
	// Get the next message and if it exists, remove it from the array
	
	if([twitterMessages count] > 0)
	{
		nextMessage = [twitterMessages objectAtIndex:0];
		[nextMessage autorelease];
		[twitterMessages removeObjectAtIndex:0];
	}
		
	return nextMessage;
}

- (void)removeAllObjects
{
	[twitterMessages removeAllObjects];
}

- (void)addMessage:(TwitterMessage*)newMessage
{
	// Just insert the message at the end of the array
	[twitterMessages addObject:newMessage];
}

- (void)refillQueue
{
	NSLog(@"Refilling tweet queue...");
	NSURL *twitterURL;
		
	// Get the twitter codument
	if(showFriendsTimeline)
	{
		
		NSLog(@"Using friends timeline.");
		NSString *urlString = @"http://";
		urlString = [urlString stringByAppendingString:userName];
		urlString = [urlString stringByAppendingString:@":"];
		urlString = [urlString stringByAppendingString:password];
		urlString = [urlString stringByAppendingString:@"@"];
		urlString = [urlString stringByAppendingString:TwitterFriendsTimelineURL];
				
		twitterURL = [[NSURL alloc] initWithString:urlString];	
	} else {
		NSLog(@"Using public timeline.");
		twitterURL = [[NSURL alloc] initWithString:TwitterPublicTimelineURL];
	}
	
	NSXMLDocument *twitterDoc = [[NSXMLDocument alloc] initWithContentsOfURL:twitterURL options:0 error:nil];
	
	NSArray *children = [[twitterDoc rootElement] children];
	int i;
	
	for (i=0; i < [children count]; i++) {
		NSXMLNode *child = [children objectAtIndex:i];
		
		TwitterMessage *newMessage = [TwitterMessage createFromXMLNode:child];
		[self addMessage:newMessage];
	}
	
	NSLog(@"Done refilling tweet queue.");
}

- (void)setShowFriendsTimeline:(BOOL)showFriends
{
	showFriendsTimeline = showFriends;
}
- (BOOL)showFriendsTimeline
{
	return showFriendsTimeline;
}
- (void)setUserName:(NSString*)user
{
	[user retain];
	[userName release];
	userName = user;
}
- (NSString*)userName
{
	return userName;
}
- (void)setPassword:(NSString*)pass
{
	[pass retain];
	[password release];
	password = pass;
}
- (NSString*)password
{
	return password;
}

@end
