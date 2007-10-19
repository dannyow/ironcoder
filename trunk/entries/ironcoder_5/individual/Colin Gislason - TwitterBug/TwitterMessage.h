//
//  TwitterMessage.h
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright 2007 Colin Gislason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterUser.h"

@interface TwitterMessage : NSObject {
	NSDate *createdDate;
	int messageId;
	NSString *text;
	TwitterUser *user;
}


- (id)initWithCreatedDate:(NSDate*)newCreatedDate
				messageId:(int)newMessageId
					 text:(NSString*)newText
					 user:(TwitterUser*)newUser;

+ (TwitterMessage*) createFromXMLNode:(NSXMLNode*)xmlNode;

// *** Setters and Getters
- (void)setCreatedDate:(NSDate*)newCreatedDate;
- (NSDate*)createdDate;
- (void)setMessageId:(int)newMessageId;
- (int)messageId;
- (void)setText:(NSString*)newText;
- (NSString*)text;
- (void)setUser:(TwitterUser*)newUser;
- (TwitterUser*)user;

@end
