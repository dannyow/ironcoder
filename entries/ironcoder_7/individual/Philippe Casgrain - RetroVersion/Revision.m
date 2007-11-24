//
//  Revision.m
//  RetroVersion
//
//  Created by Philippe on 14/11/07.
//  Copyright 2007 Philippe Casgrain. All rights reserved.
//

#import "Revision.h"


@implementation Revision

- (Revision*) initWithRevisionNumber: (NSNumber*) num author: (NSString*) auth logMessage: (NSString*) msg commitDate: (NSDate*) date
{
	if (self = [super init])
	{
		revisionNumber = num;
		author = auth;
		message = msg;
		commitDate = date;
		annotatedListing = nil;
	}
	return self;
}

- (void) setTextWithFile: (NSString*) fileName deleting: (BOOL) deleteFile
{
	NSError* err;
	NSString* revText = [NSString stringWithContentsOfFile: fileName encoding: NSASCIIStringEncoding error: &err];
	//NSLog(@"Error: %@ while opening %@", err, fileName);
	if (nil == revText)
	{
		revText = @"Please wait...";
	}
	annotatedListing = revText;

	if (deleteFile)
	{
		[[NSFileManager defaultManager] removeItemAtPath: fileName error: &err];
	}
}

- (NSNumber*) revision 
{ 
	return revisionNumber; 
}

- (NSString*) annotatedListing
{
	return annotatedListing;
}

- (NSString*) commitMessage
{
	return message;
}

- (NSDate*) commitDate
{
	return commitDate;
}

@end
