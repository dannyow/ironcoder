//
//  TwitterUser.m
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright 2007 Colin Gislason. All rights reserved.
//

#import "TwitterUser.h"

@implementation TwitterUser

static NSString * const TWITTER_ID = @"id";
static NSString * const TWITTER_NAME = @"name";
static NSString * const TWITTER_SCREEN_NAME = @"screen_name";
static NSString * const TWITTER_LOCATION = @"location";
static NSString * const TWITTER_DESCRIPTION = @"description";
static NSString * const TWITTER_PROFILE_IMAGE_URL = @"profile_image_url";
static NSString * const TWITTER_URL = @"url";

- (id) init
{
	self = [super init];
    if (self) {
		
    }
    return self;
}

- (id)initWithUserId:(int)newId
				name:(NSString*)newName
		  screenName:(NSString*)newScreenName
			location:(NSString*)newLocation
		 description:(NSString*)newDescription
	 profileImageURL:(NSURL*)newProfileImage
				 URL:(NSURL*)newURL
{
	self = [super init];
    if (self) {
		[self setName:newName];
		[self setScreenName:newScreenName];
		[self setLocation:newLocation];
		[self setDescription:newDescription];
		[self setProfileImageURL:newProfileImage];
		[self setURL:newURL];
    }
    return self;
}

- (id)initWithUserId:(int)newId
				name:(NSString*)newName
		  screenName:(NSString*)newScreenName
			location:(NSString*)newLocation
		 description:(NSString*)newDescription
		profileImageURLFromString:(NSString*)newProfileImage
				 URLFromString:(NSString*)newURL
{
	self = [super init];
    if (self) {
		[self setName:newName];
		[self setScreenName:newScreenName];
		[self setLocation:newLocation];
		[self setDescription:newDescription];
		[self setProfileImageURLFromString:newProfileImage];
		[self setURLFromString:newURL];
    }
    return self;
}

- (void)dealloc
{
	NSLog(@"dealloc in TwitterUser");
	[super dealloc];
	[name release];
	[screenName release];
	[location release];
	[description release];
	[profileImageURL release];
	[URL release];
}


+ (TwitterUser*) createFromXMLNode:(NSXMLNode*)xmlNode
{
	int i;
	
	[xmlNode retain];
	
	TwitterUser *newUser = [[TwitterUser alloc] init];
		
	NSXMLNode *curChild;
	NSArray *children = [xmlNode children];
	 
	// Fill in each attribute from the XML if it appears
	for ( i = 0; children && i < [children count]; i++ )
	{
		curChild = [children objectAtIndex:i];
				
		if([[curChild name] compare:TWITTER_ID] == NSOrderedSame)
		{
			int newId = [[curChild stringValue] intValue];
			[newUser setUserId:newId];
		}
		else if([[curChild name] compare:TWITTER_NAME] == NSOrderedSame)
		{
			[newUser setName:[curChild stringValue]];			
		}
		else if([[curChild name] compare:TWITTER_SCREEN_NAME] == NSOrderedSame)
		{
			[newUser setScreenName:[curChild stringValue]];			
		}
		else if([[curChild name] compare:TWITTER_LOCATION] == NSOrderedSame)
		{
			[newUser setLocation:[curChild stringValue]];			
		}
		else if([[curChild name] compare:TWITTER_DESCRIPTION] == NSOrderedSame)
		{
			[newUser setDescription:[curChild stringValue]];			
		}
		else if([[curChild name] compare:TWITTER_PROFILE_IMAGE_URL] == NSOrderedSame)
		{
			[newUser setProfileImageURLFromString:[curChild stringValue]];			
		}
		else if([[curChild name] compare:TWITTER_URL] == NSOrderedSame)
		{
			[newUser setURLFromString:[curChild stringValue]];			
		}
			
	}
	
	[xmlNode release];
	
	return newUser;
}


// *** Getters and Setters

- (void)setUserId:(int)newId;
{
	userId = newId;
}
- (int)userId
{
	return userId;
}

- (void)setName:(NSString*)newName
{
	[newName retain];
	[name release];
	name = newName;
}
- (NSString*)name
{
	return name;
}

- (void)setScreenName:(NSString*)newScreenName
{
	[newScreenName retain];
	[screenName release];
	screenName = newScreenName;
}
- (NSString*)screenName
{
	return screenName;
}
- (void)setLocation:(NSString*)newLocation
{
	[newLocation retain];
	[location release];
	location = newLocation;
}
- (NSString*)location
{
	return location;
}

- (void)setDescription:(NSString*)newDescription
{
	[newDescription retain];
	[description release];
	description = newDescription;
}
- (NSString*)description
{
	return description;
}

- (void)setProfileImageURL:(NSURL*)newProfileImageURL
{
	[newProfileImageURL retain];
	[profileImageURL release];
	profileImageURL = newProfileImageURL;
}
- (void)setProfileImageURLFromString:(NSString*)newProfileImageURLString
{
	NSURL *newURL = [[NSURL alloc] initWithString:newProfileImageURLString];
	[newURL retain];
	[profileImageURL release];
	profileImageURL = newURL;
	
}
- (NSURL*)profileImageURL
{
	return profileImageURL;
}

- (void)setURL:(NSURL*)newURL
{
	[newURL retain];
	[URL release];
	URL = newURL;	
}
- (void)setURLFromString:(NSString*)newURLString
{
	NSURL *newURL = [[NSURL alloc] initWithString:newURLString];
	[newURL retain];
	[URL release];
	URL = newURL;
}
- (NSURL*)URL
{
	return URL;
}

@end
