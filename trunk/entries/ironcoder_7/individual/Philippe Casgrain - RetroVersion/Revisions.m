//
//  Revisions.m
//  RetroVersion
//
//  Created by Philippe on 07-11-14.
//  Copyright 2007 Philippe Casgrain. All rights reserved.
//

#import "Revisions.h"
#import "NSNumberAdditions.h"
#import "NSDateAdditions.h"
#import "Revision.h"

@implementation Revisions

#define kPadding 20.0f

- (Revisions*) initWithXMLDocument: (NSXMLDocument*) doc sourceURL: (NSString*) url
{
	if (self= [super init])
	{
		srcUrl = [NSString stringWithString: url];
		NSError* err;
		NSArray* logEntries = [doc nodesForXPath:@"./log/logentry" error: &err];
		
		elements = [NSMutableArray arrayWithCapacity: [logEntries count]];
		
		int i;
		for (i = 0; i < [logEntries count]; i++)
		{
			NSXMLElement* logEntry = [logEntries objectAtIndex: i];
			NSNumber* revision = [NSNumber numberWithString: [[logEntry attributeForName:@"revision"] stringValue]];
			NSString* author = [[[logEntry elementsForName: @"author"] objectAtIndex: 0] stringValue];
			NSString* message = [[[logEntry elementsForName: @"msg"] objectAtIndex: 0] stringValue];
			NSDate* date = [NSDate dateWithSVNString: [[[logEntry elementsForName: @"date"] objectAtIndex: 0] stringValue]];
			Revision* rev = [[Revision alloc] initWithRevisionNumber: revision author: author logMessage: message commitDate: date];
			[elements insertObject: rev atIndex: i];
		}
	}
	return self;
}

- (NSString*) sourceURL
{ 
	return srcUrl; 
}

- (NSArray*) elements
{
	return elements;
}

@end
