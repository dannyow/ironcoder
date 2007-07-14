//
//  FlickrParser.m
//  BlurredLife
//
//  Created by Adam Leonard on 3/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FlickrParser.h"

#define FLICKR_REQUEST_BASE_URL @"http://api.flickr.com/services/rest/"
#define FLICKR_API_KEY @"52d75d869d3366971a648b5e7f16836e" //don't steal this por favor

@implementation FlickrParser

- (id)initWithFlickrGroupID:(NSString *)groupID
				   delegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) 
	{
		delegate = aDelegate;
		
		int maxNumberOfResults = 100;
		
		//put together the request URL
		_URL = [[NSURL URLWithString:[[NSString stringWithFormat:@"%@?method=flickr.groups.pools.getPhotos&api_key=%@&group_id=%@&per_page=300",FLICKR_REQUEST_BASE_URL,FLICKR_API_KEY,groupID]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]retain];
		
		
		_results = [[NSMutableArray alloc]initWithCapacity:maxNumberOfResults];
	}
	return self;
}
- (void)retrievePhotoURLs;
{	
	if(!_URL)
		return;
	
	NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:_URL];
	
	if(!parser)
	{
		NSLog(@"***Could not create parser!***");
		[self informDelegateOfFailure];
		return;
	}
	[parser setDelegate:self];
	[parser setShouldResolveExternalEntities:YES];
	
	if(![parser parse])
	{
		NSLog(@"***Could not begin parse***");
		[self informDelegateOfFailure];
		return;
	}
	
}

#pragma mark parser delegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
	if(![elementName isEqualToString:@"photo"])
		return;
	
	
	//get all the info to put together a photo URL (see http://www.flickr.com/services/api/misc.urls.html)
	NSString *photoID = [attributeDict objectForKey:@"id"];
	NSString *secret = [attributeDict objectForKey:@"secret"];
	NSString *server = [attributeDict objectForKey:@"server"];
	NSString *farm = [attributeDict objectForKey:@"farm"];
	
	if(!photoID|| !secret || !server || !farm)
	{
		NSLog(@"***Could not make URL for photo ***");
		return;
	}
				
	NSURL *photoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@.jpg",farm,server,photoID,secret]];
	
	if(photoURL)
		[_results addObject:photoURL];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
	
	if(!_results || [_results count] == 0)
	{
		NSLog(@"No photos found");
		
		[self informDelegateOfFailure];
		
		return;
	}
	if([delegate respondsToSelector:@selector(flickrParser:didFindPhotoURLs:)])
		[delegate flickrParser:self didFindPhotoURLs:[[_results copy]autorelease]];
	
	
	[parser release];
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"*** Parser error occured! : %@ ***",[parseError description]);
	
	[parser abortParsing];
	[parser autorelease];
	
	[self informDelegateOfFailure];
}



-(void)informDelegateOfFailure;
{	
	if([delegate respondsToSelector:@selector(flickrParser:didFindPhotoURLs:)])
		[delegate flickrParser:self didFindPhotoURLs:nil];
}

- (void) dealloc 
{
	[_results release];
	[_URL release];
	[super dealloc];
}


@end
