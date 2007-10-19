//
//  TwitterMessage.m
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright 2007 Colin Gislason. All rights reserved.
//

#import "TwitterMessage.h"


@implementation TwitterMessage

static NSString * const TWITTER_CREATED_AT = @"created_at";
static NSString * const TWITTER_ID = @"id";
static NSString * const TWITTER_TEXT = @"text";
static NSString * const TWITTER_USER = @"user";

- (id)init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}

- (id)initWithCreatedDate:(NSDate*)newCreatedDate
				messageId:(int)newMessageId
					 text:(NSString*)newText
					 user:(TwitterUser*)newUser
{
	self = [super init];
	if(self)
	{
		[self setCreatedDate:newCreatedDate];
		[self setMessageId:newMessageId];
		[self setText:newText];
		[self setUser:newUser];
	}
	return self;
}

+ (TwitterMessage*) createFromXMLNode:(NSXMLNode*)xmlNode
{
	[xmlNode retain];
	
	int i;
	
	TwitterMessage *newMessage = [[TwitterMessage alloc] init];
	
	NSXMLNode *curChild;
	
	// Fill in each attribute from the XML if it appears
	for ( i = 0; i < [xmlNode childCount]; i++ )
	{		
		curChild = [xmlNode childAtIndex:i];
		
		//NSLog(@"entering message attribute = %@ : %@", [curChild name], [curChild stringValue]);
		
		if([[curChild name] compare:TWITTER_TEXT] == NSOrderedSame)
		{
			[newMessage setText:[curChild stringValue]];
		}
		else if([[curChild name] compare:TWITTER_ID] == NSOrderedSame)
		{
			int newId = [[curChild stringValue] intValue];
			[newMessage setMessageId:newId];
		}
		else if([[curChild name] compare:TWITTER_CREATED_AT] == NSOrderedSame)
		{			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%a %b %e %H:%M:%S %z %Y" allowNaturalLanguage:NO];
			NSDate *date = [dateFormatter dateFromString:[curChild stringValue]];
			
			if(date)
			{
				// Why do I have to retain here, but releasing breaks it?
				[date retain];
				[newMessage setCreatedDate:date];			
			}
			
			[dateFormatter release];
		}
		else if([[curChild name] compare:TWITTER_USER] == NSOrderedSame)
		{
			TwitterUser *newUser = [TwitterUser createFromXMLNode:curChild];
			[newMessage setUser:newUser];
		}
	}
	
	[xmlNode release];
	
	return newMessage;
}

- (void)dealloc
{
	NSLog(@"dealloc in TwitterMessage");
	[super dealloc];
	[createdDate release];
	[text release];
	[user release];
}

- (NSString*)description
{	
	return [NSString stringWithFormat:@"%@: %@", [[self user] screenName], [self text]];
}


// *** Setters and Getters

- (void)setCreatedDate:(NSDate*)newCreatedDate
{
	[newCreatedDate retain];
	[createdDate release];
	createdDate = newCreatedDate;
}
- (NSDate*)createdDate
{
	return createdDate;
}

- (void)setMessageId:(int)newMessageId
{
	messageId = newMessageId;
}
- (int)messageId
{
	return messageId;
}

- (void)setText:(NSString*)newText
{
	[newText retain];
	[text release];
	text = newText;
}
- (NSString*)text
{
	return text;
}

- (void)setUser:(TwitterUser*)newUser
{
	[newUser retain];
	[user release];
	user = newUser;
}
- (TwitterUser*)user
{
	return user;
}

@end
