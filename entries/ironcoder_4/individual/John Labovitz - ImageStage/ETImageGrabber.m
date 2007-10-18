//
//  ETImageGrabber.m
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import "ETImageGrabber.h"


@interface ETImageGrabber(ETImageGrabberPrivate)

- (int)totalResultsAvailable;

- (NSDictionary *)runQueryFromPosition:(int)start;	

- (NSURL *)queryURLFromPosition:(unsigned)start
					 maxResults:(unsigned)maxResults;

@end


@implementation ETImageGrabber


// see: http://developer.yahoo.com/search/image/V1/imageSearch.html

#define	YAHOO_APP_STRING	@"ImageRadar"


- (id)initWithQuery:(NSString *)query {
	
	if ((self = [self init]) != nil) {
		
		_query = [query retain];
		
		srandomdev();
		
		_history = [[NSMutableDictionary dictionary] retain];
		_connections = [[NSMutableArray array] retain];
	}
	
	return self;
}


- (void)dealloc {
	
	[_query release];
	[_connections release];
	[_history release];
		
	[super dealloc];
}


#pragma mark Properties


- (id)delegate { return _delegate; }
- (void)setDelegate:(id)delegate { _delegate = delegate; }


- (NSMutableArray *)connections { return [[_connections retain] autorelease]; }
- (void)setConnections:(NSMutableArray *)connections { if (connections != _connections) { [_connections release]; _connections = [connections retain]; } }


#pragma mark Methods


- (BOOL)isDownloading {
	
	return [_connections count] > 0;
}


- (void)grabImage {
		
	while (TRUE) {
		
		NSDictionary *response = [self runQueryFromPosition:random() % [self totalResultsAvailable]];
		NSArray *results = [response objectForKey:@"results"];
		int i;
		
		for (i = 0; i < [results count]; i++) {
			
			NSDictionary *result = [results objectAtIndex:i];
			NSURL *url = [result objectForKey:@"url"];
			long size = [[result objectForKey:@"size"] longValue];
			
			if (![_history objectForKey:url] && size > 50*1024 && size < 100*1024) {
				
				NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					url,							@"url",
					[NSNumber numberWithInt:size],	@"size",
					[NSMutableData data],			@"data",
					nil];
				
				[_history setObject:info
							 forKey:url];
				
				[[self delegate] performSelector:@selector(imageWillDownload:)
									  withObject:[[info copy] autorelease]];
				
				NSURLRequest *request = [NSURLRequest requestWithURL:url
														 cachePolicy:NSURLRequestUseProtocolCachePolicy
													 timeoutInterval:5.0];
				NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request
																			   delegate:self] autorelease];
				
				if (connection) {
					
					[info setObject:connection
							 forKey:@"connection"];
					
					[_connections addObject:info];
					
				} else {
					
					[[self delegate] performSelector:@selector(imageDidFailToDownload:)
										  withObject:[[info copy] autorelease]];
				}
				
				return;
			}
		}
	}
}


- (NSMutableDictionary *)infoForConnection:(NSURLConnection *)connection {
	
	int i;
	for (i = 0; i < [_connections count]; i++) {
		
		NSMutableDictionary *info = [_connections objectAtIndex:i];
		
		if ([[info objectForKey:@"connection"] isEqual:connection]) {
			
			return info;
		}
	}
	
	return nil;
}


- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response {
		
	NSMutableDictionary *info = [self infoForConnection:connection];
	
	NSMutableData *imageData = [info objectForKey:@"data"];

    [imageData setLength:0];
}


- (void)connection:(NSURLConnection *)connection 
	didReceiveData:(NSData *)data {

	NSMutableDictionary *info = [self infoForConnection:connection];

	NSMutableData *imageData = [info objectForKey:@"data"];

    [imageData appendData:data];
}

	
- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error {

	NSMutableDictionary *info = [self infoForConnection:connection];
	
	[info setObject:error
			 forKey:@"error"];

	[[self delegate] performSelector:@selector(imageDidFailToDownload:)
						  withObject:[[info copy] autorelease]];

	[_connections removeObject:info];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
		
	NSMutableDictionary *info = [self infoForConnection:connection];

	NSImage *image = [[[NSImage alloc] initWithData:[info objectForKey:@"data"]] autorelease];
	
	[info removeObjectForKey:@"data"];
	
	if (image) {
		
		[info setObject:image
				 forKey:@"image"];
		
		[[self delegate] performSelector:@selector(imageDidDownload:)
							  withObject:[[info copy] autorelease]];
		
		[info removeObjectForKey:@"image"];
		
	} else {
		
		[[self delegate] performSelector:@selector(imageDidFailToDownload:)
							  withObject:[[info copy] autorelease]];		
	}

	[_connections removeObject:info];
}


- (NSDictionary *)runQueryFromPosition:(int)start {
		
	NSError *error = nil;
	NSXMLDocument *xml = [[[NSXMLDocument alloc] initWithContentsOfURL:[self queryURLFromPosition:start
																					   maxResults:10]
															   options:0
																 error:&error] autorelease];
	;;NSAssert(!error, [error description]);
	
	//;;NSLog(@"xml = %@, error = %@", xml, error);
	
	int totalResultsAvailable = 1000;	//FIXME -- should get from ResultSet element
	
	NSArray *resultNodes = [xml nodesForXPath:@"//Result"
										error:&error];
	;;NSAssert(!error, [error description]);
		
	NSEnumerator *resultNodesEnumerator = [resultNodes objectEnumerator];
	NSXMLNode *resultNode;
	NSMutableArray *results = [NSMutableArray array];

	while ((resultNode = [resultNodesEnumerator nextObject]) != nil) {
		
		NSArray *fileSizeNodes = [resultNode nodesForXPath:@"FileSize"
													 error:&error];
		;;NSAssert(!error, [error description]);
		
		long size = [[[fileSizeNodes objectAtIndex:0] stringValue] intValue];
		
		NSArray *urlNodes = [resultNode nodesForXPath:@"Url"
												error:&error];
		;;NSAssert(!error, [error description]);
		
		NSURL *url = [NSURL URLWithString:[[urlNodes objectAtIndex:0] stringValue]];
		
		[results addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			url,								@"url",
			[NSNumber numberWithLong:size],		@"size",
			nil]];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:totalResultsAvailable],	@"totalResultsAvailable",
		results,										@"results",
		nil];
}


- (NSURL *)queryURLFromPosition:(unsigned)start
					 maxResults:(unsigned)maxResults {
		
	NSString *queryString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																				(CFStringRef)_query, 
																				NULL, 
																				NULL, 
																				kCFStringEncodingUTF8);
	[queryString autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.search.yahoo.com/ImageSearchService/V1/imageSearch?appid=%@&query=%@&format=%@&start=%@&results=%@",
		YAHOO_APP_STRING,
		queryString,
		@"jpeg",
		[NSNumber numberWithInt:start],
		[NSNumber numberWithInt:maxResults]];
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	return url;
}


- (int)totalResultsAvailable {
	
	if (_totalResultsAvailable == 0) {
		
		NSDictionary *response = [self runQueryFromPosition:1];
		_totalResultsAvailable = [[response objectForKey:@"totalResultsAvailable"] intValue];
	}
	
	return _totalResultsAvailable;	
}


@end