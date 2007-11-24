//
//  Revisions.h
//  RetroVersion
//
//  Created by Philippe on 07-11-14.
//  Copyright 2007 Philippe Casgrain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Revision;

@interface Revisions : NSObject 
{
	NSMutableArray* elements;
	NSString* srcUrl;
}

- (Revisions*) initWithXMLDocument: (NSXMLDocument*) doc sourceURL: (NSString*) url;
- (NSString*) sourceURL;
- (NSArray*) elements;

@end
