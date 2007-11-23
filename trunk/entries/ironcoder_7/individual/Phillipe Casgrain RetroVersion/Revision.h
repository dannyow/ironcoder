//
//  Revision.h
//  RetroVersion
//
//  Created by Philippe on 14/11/07.
//  Copyright 2007 Philippe Casgrain. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Revision : NSObject 
{
	NSNumber* revisionNumber;
	NSString* author;
	NSString* message;
	NSDate* commitDate;
	NSString* annotatedListing;
}

- (Revision*) initWithRevisionNumber: (NSNumber*) num author: (NSString*) auth logMessage: (NSString*) msg commitDate: (NSDate*) date;
- (void) setTextWithFile: (NSString*) fileName deleting: (BOOL) deleteFile;
- (NSNumber*) revision;
- (NSString*) annotatedListing;
- (NSString*) commitMessage;
- (NSDate*) commitDate;

@end
