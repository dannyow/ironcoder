//
//  MCTwitter.m
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/30/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "MCTwitter.h"

#define kUser @"user"
#define kStatus @"status"

@implementation MCTwitter

#pragma mark -
#pragma mark init

- (id)initWithLogin:(NSString *)login password:(NSString *)password forCall:(TwitterRemoteCall) call {

	self = [super init];

	if (self) {
		_login = [login retain];
		_password = [password retain];
		
		switch(call) {
			case MCTwitter_publicTimeline: 
				_url = [[NSURL URLWithString:@"http://twitter.com/statuses/public_timeline.xml"] retain];
				break;
			case MCTwitter_friendsTimeline:
				_url = [[NSURL URLWithString:@"http://twitter.com/statuses/friends_timeline.xml"] retain];
				break;
			case MCTwitter_friends:
				_url = [[NSURL URLWithString:@"http://twitter.com/statuses/friends.xml"] retain];			
				break;
			case MCTwitter_followers:
				_url = [[NSURL URLWithString:@"http://twitter.com/statuses/followers.xml"] retain];
				break;
			default:
				_url = [[NSURL URLWithString:@"http://twitter.com/statuses/public_timeline.xml"] retain];
		}

	}

	return self;

}

- (void)setDelegate:(id)delegate {
	_delegate = delegate;
}

- (void)dealloc {

	[_login release];
	[_password release];
	[_returnArray autorelease];
	
	[super dealloc];
}

- (void)returnErrorTwitter {
	NSDictionary *status = [NSDictionary dictionaryWithObjectsAndKeys:[[NSCalendarDate date] description], @"created_at", @"Check the username and password entered under\nthe screen saver options and make sure you are connected to the internet.", @"text", nil];
	NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:@"You Got a Dud", @"name", @"http://www.aimface.com/ikons/IKON47df2c4e14884fefff62f6117eb21c529a790e9bae.gif", @"profile_image_url", nil];
	[_delegate twitter:self didReceiveResponse:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:user, kUser, status, kStatus, nil]]];
}

- (void)request {

	// create the request
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		_receivedData=[[NSMutableData data] retain];
	} else {
		[self returnErrorTwitter];
		//NSLog(@"Could not create NSURLConnection");
	}

}

#pragma mark -
#pragma mark NSURLConnection

//Basically straight from http://developer.apple.com/documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
 
    // it can be called multiple times, for example in the case of a 
    // redirect, so each time we reset the data.
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// append the new data to the receivedData
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // do something with the data
    //NSLog(@"Succeeded! Received %d bytes of data:\n\n%@",[receivedData length], [[[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding] autorelease]);
 
	[_returnArray release];
	_returnArray = [NSMutableArray array];
 
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:_receivedData] autorelease];
    [parser setDelegate:self];
    [parser parse];
 
	//NSLog([_returnArray description]);
 
	//NSLog(@"delegate being run.");
 
	[_delegate twitter:self didReceiveResponse:[NSArray arrayWithArray:_returnArray]];  //delegates have to respond to this method.
 
    // release the connection, and the data object
    [connection release];
    [_receivedData release];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    NSURLRequest *newRequest=request;
    if (redirectResponse) {
        newRequest=nil;
    }
    return newRequest;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [connection release];
    [_receivedData release];
	[self returnErrorTwitter];
    // inform the user
    //NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	//NSLog(@"I command you not to cache.");
	return nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	//NSLog(@"argh. (\"\\(.:..:.)/\")");
	
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:_login password:_password persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
		[self returnErrorTwitter];
        // inform the user that the user name and password
        // in the preferences are incorrect
        //[self showPreferencesCredentialsAreIncorrectPanel:self];
		//NSLog(@"show some preferencecs panel or something saying login/pass are bad.");
    }
}

#pragma mark -
#pragma mark XML Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:kUser]) {
		_currentUser = [NSMutableDictionary dictionary];
	} else if ([elementName isEqualToString:kStatus]) {
		_currentStatus = [NSMutableDictionary dictionary];	
	} else if ( [elementName isEqualToString:@"created_at"] ||
				[elementName isEqualToString:@"text"] ||
				[elementName isEqualToString:@"name"] ||
				[elementName isEqualToString:@"location"] ||
				[elementName isEqualToString:@"description"] ||
				[elementName isEqualToString:@"profile_image_url"] ||
				[elementName isEqualToString:@"url"] ) { //if a user or status is open get the key
		_currentKey = [elementName retain];
	}
	
	//NSLog(@"didStartElement:%@\tnamespaceURI:%@\tqualifiedName:%@", elementName, namespaceURI, qName);
	//NSLog(@"attribultes:%@", [attributeDict description]);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (_currentKey != nil) {
		if ([_currentKey isEqualToString:@"created_at"] || [_currentKey isEqualToString:@"text"]) {
			[_currentStatus setObject:string forKey:_currentKey];
		} else {
			[_currentUser setObject:string forKey:_currentKey];		
		}
		
		[_currentKey release];
		_currentKey = nil;
	}
	//NSLog(@"foundCharacters:%@", string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//NSLog(@"didEndElement:%@\tnamespaceURI:%@\tqualifiedName:%@", elementName, namespaceURI, qName);
	
	if (([elementName isEqualToString:kUser] || [elementName isEqualToString:kStatus]) && ([_currentStatus count] == 2 && [_currentUser count] == 5) ) {
		[_returnArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:_currentUser, kUser, _currentStatus, kStatus, nil]];
		[_currentStatus setObject:@"Added." forKey:@"quickHackFix"];
	}
}

@end
