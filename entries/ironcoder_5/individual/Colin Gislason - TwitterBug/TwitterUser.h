//
//  TwitterUser.h
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright 2007 Colin Gislason. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TwitterUser : NSObject {
	int userId;
	NSString *name;
	NSString *screenName;
	NSString *location;
	NSString *description;
	NSURL *profileImageURL;
	NSURL *URL;
}

- (id)initWithUserId:(int)newId
				name:(NSString*)newName
		  screenName:(NSString*)newScreenName
			location:(NSString*)newLocation
		 description:(NSString*)newDescription
		profileImageURL:(NSURL*)newProfileImage
				 URL:(NSURL*)newURL;

- (id)initWithUserId:(int)newId
				name:(NSString*)newName
		  screenName:(NSString*)newScreenName
			location:(NSString*)newLocation
		 description:(NSString*)newDescription
		profileImageURLFromString:(NSString*)newProfileImage
	   URLFromString:(NSString*)newURL;

+ (TwitterUser*) createFromXMLNode:(NSXMLNode*)xmlNode;

- (void)setUserId:(int)newId;
- (int)userId;
- (void)setName:(NSString*)newName;
- (NSString*)name;
- (void)setScreenName:(NSString*)newScreenName;
- (NSString*)screenName;
- (void)setLocation:(NSString*)newLocation;
- (NSString*)location;
- (void)setDescription:(NSString*)newDescription;
- (NSString*)description;
- (void)setProfileImageURL:(NSURL*)newProfileImageURL;
- (void)setProfileImageURLFromString:(NSString*)newProfileImageURLString;
- (NSURL*)profileImageURL;
- (void)setURL:(NSURL*)newURL;
- (void)setURLFromString:(NSString*)newURLString;
- (NSURL*)URL;

@end
