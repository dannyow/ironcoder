//
//  CFlickrFeed.m
//  Space
//
//  Created by Jonathan Wight on 10/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CFlickrFeed.h"

#import "CJSONScanner.h"
#import "CIImage_Extensions.h"

@implementation CFlickrFeed

+ (void)initialize
{
[self setKeys:[NSArray arrayWithObjects:@"image", NULL] triggerChangeNotificationsForDependentKey:@"coreImage"];
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	imageUrls = [[NSMutableArray alloc] init];
	images = [[NSMutableArray alloc] init];
	[self setMode:FlickrFeedMode_DownloadingFeed];
	
	NSTimer *theTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(imageRefreshTimer:) userInfo:NULL repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSEventTrackingRunLoopMode];
	}
return(self);
}

- (void)dealloc
{
[self setImage:NULL];
[imageUrls autorelease];
[images autorelease];
[data autorelease];
[connection autorelease];
//
[super dealloc];
}

#pragma mark -

- (EFlickrFeedMode)mode
{
return(mode);
}

- (void)setMode:(EFlickrFeedMode)inMode
{
mode = inMode;

if (inMode == FlickrFeedMode_DownloadingFeed)
	{
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne?tags=space&format=json"]];
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
	connection = [theConnection retain];
	}
else if (inMode == FlickrFeedMode_DownloadingImage)
	{
	if ([imageUrls count] > 0)
		{
		NSURL *theURL = [[[imageUrls objectAtIndex:0] copy] autorelease];
		[imageUrls removeObjectAtIndex:0];

		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL];

		NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
		connection = [theConnection retain];
		}
	}
}

- (NSImage *)image
{
return(image); 
}

- (void)setImage:(NSImage *)inImage
{
if (image != inImage)
    {
	[image autorelease];
	image = [inImage retain];
    }
}

- (CIImage *)coreImage
{
return([CIImage imageWithNSImage:[self image]]);
}

#pragma mark -

- (void)imageRefreshTimer:(id)inParameter
{
if ([images count] > 0)
	{
	if ([self image] == NULL)
		{
		[self setImage:[images objectAtIndex:0]];
		}
	else
		{
		unsigned theCurrentImageIndex = [images indexOfObject:[self image]];
		unsigned theNextImageIndex = (theCurrentImageIndex + 1) % [images count];
		[self setImage:[images objectAtIndex:theNextImageIndex]];
		}
	}

}

#pragma mark -

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)inData
{
#pragma unused (inConnection)

if (data == NULL)
	{
	data = [[NSMutableData alloc] initWithData:inData];
	}
else
	{
	[data appendData:inData];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection;
{
#pragma unused (inConnection)

if ([self mode] == FlickrFeedMode_DownloadingFeed)
	{
	NSString *theJSONFeed = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSScanner *theScanner = [NSScanner scannerWithString:theJSONFeed];
	BOOL theResult = [theScanner scanString:@"jsonFlickrFeed" intoString:NULL];
	if (theResult == NO) [NSException raise:NSGenericException format:@"Doesn't look like a valid Flickr JSON feed to me."];
	
	id theObject = NULL;
	theResult = [theScanner scanJSONObject:&theObject];
	if (theResult == NO) [NSException raise:NSGenericException format:@"Doesn't look like valid JSON to me."];

	theObject = [theObject objectAtIndex:0];

	NSArray *theURLStrings = [[theObject objectForKey:@"items"] valueForKeyPath:@"media.m"];
	NSEnumerator *theEnumerator = [theURLStrings objectEnumerator];
	NSString *theURLString = NULL;

	while ((theURLString = [theEnumerator nextObject]) != NULL)
		{
		[imageUrls addObject:[NSURL URLWithString:theURLString]];
		}

	[data autorelease];
	data = NULL;

	[connection autorelease];
	connection = NULL;

	[self setMode:FlickrFeedMode_DownloadingImage];
	}
else if ([self mode] == FlickrFeedMode_DownloadingImage)
	{
	NSImage *theImage = [[[NSImage alloc] initWithData:data] autorelease];
	
	[images addObject:theImage];
	if ([self image] == NULL)
		{
		[self setImage:theImage];
		}

	[data autorelease];
	data = NULL;

	[connection autorelease];
	connection = NULL;

	[self setMode:FlickrFeedMode_DownloadingImage];
	}
}

@end
