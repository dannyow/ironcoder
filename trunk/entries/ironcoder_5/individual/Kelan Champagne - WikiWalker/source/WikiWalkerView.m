//
//  WikiWalkerView.m
//  WikiWalker
//
//  Created by Kelan Champagne on 3/31/07.
//  Copyright (c) 2007, Yeah Right Keller. All rights reserved.
//

#import "WikiWalkerView.h"


@implementation ComYeahRightKeller_WikiWalkerView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
		
		webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)
                                       frameName:@"YRKmainFrame"
                                       groupName:@"YRKgroup"];
		[webView setFrameLoadDelegate:self];
		
		startingURL = [[NSString alloc] initWithString:@"http://en.wikipedia.org/wiki/Life_%28disambiguation%29"];
		periodLength = 15.0;	// seconds
		transitionLength = 5.0;	// seconds
		
		currentPageTitle = [[NSString alloc] initWithString:@"Loading..."];
		nextPageTitle = [[NSString alloc] initWithString:@"NextTitle"];
		
		// Create the title attributes dictions
		titleAttributes = [[NSMutableDictionary alloc] init];
		float fontSize = frame.size.height * 0.15;
		[titleAttributes setObject:[NSFont fontWithName:@"Lucida Grande" size:fontSize]
							forKey:NSFontAttributeName];
		[titleAttributes setObject:[NSColor colorWithDeviceRed:0.98 green:0.74 blue:0.14 alpha:1.0]
							forKey:NSForegroundColorAttributeName];
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(fontSize*0.025,fontSize*-0.025)];
		[shadow setShadowColor:[NSColor blackColor]];
		[shadow setShadowBlurRadius:fontSize*0.15];
		[titleAttributes setObject:shadow forKey:NSShadowAttributeName];
		titleOrigin = NSMakePoint(10,10);
		
		frameCounter = 0;
		
		// Register to see when webview is done loading
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(webViewDidFinishLoading:)
													 name:WebViewProgressFinishedNotification
												   object:nil];
		
		listOfWikiLinks = [[NSMutableArray alloc] init];
		switchTimer = [[NSTimer alloc] init];
    }
    return self;
}

- (void) dealloc {
	[webView release];
	[startingURL release];
	[titleAttributes release];
	
	[currentImage release];
	[nextImage release];
	[currentPageTitle release];
	[nextPageTitle release];
	
	[listOfWikiLinks release];
	[switchTimer release];

	[super dealloc];
}


//------------------------------------------------------------------------------
#pragma mark -
#pragma mark Drawing
//------------------------------------------------------------------------------

- (void)startAnimation {
	[super startAnimation];
	periodStartTime = CFAbsoluteTimeGetCurrent();
	[self startLoadingPageFromURL:[NSURL URLWithString:startingURL]];
}

- (void)stopAnimation {
    [super stopAnimation];
}

- (BOOL)isOpaque {
	return YES;
}

- (void)drawRect:(NSRect)rect {
	float elapsedTime = CFAbsoluteTimeGetCurrent()-periodStartTime;
    [super drawRect:rect];
	float fraction;
	if(elapsedTime >= periodLength - transitionLength) {
		[nextImage drawInRect:nextToRect fromRect:nextFromRect operation:NSCompositeSourceOver fraction:1.0];
		fraction = (periodLength-elapsedTime)/transitionLength;
	}
	else {
		fraction = 1.0;
	}
	[currentImage drawInRect:currentToRect fromRect:currentFromRect operation:NSCompositeSourceOver fraction:fraction];
	[currentPageTitle drawAtPoint:titleOrigin withAttributes:titleAttributes];
}

- (void)animateOneFrame {
	float elapsedTime = CFAbsoluteTimeGetCurrent()-periodStartTime;
	frameCounter++;
	if(currentImage != nil) {
		NSRect bounds = [self bounds];

		// Move and zoom
		float zoomFactor = 1+(bounds.size.width-currentToRect.size.width)/50000;
		if(zoomFactor < 1.005) {
			zoomFactor = 1.005;
		}
		
		currentToRect.origin.y -= (currentToRect.size.height*currentFocalHeight+currentToRect.origin.y-bounds.size.height/2)/10;
		currentToRect.size.width *= zoomFactor;
		currentToRect.size.height *= zoomFactor;
		currentToRect.origin.x = (bounds.size.width-currentToRect.size.width)/2; // keep it centered horizontally

		if(elapsedTime >= periodLength - transitionLength) {
			// fade to next page
			float nextZoomFactor = 1+(bounds.size.width-nextToRect.size.width)/50000;
			nextToRect.origin.y -= (nextToRect.size.height*nextFocalHeight+nextToRect.origin.y-bounds.size.height/2)/10;
			nextToRect.size.width *= nextZoomFactor;
			nextToRect.size.height *= nextZoomFactor;
			nextToRect.origin.x = (bounds.size.width-nextToRect.size.width)/2; // keep it centered horizontally
		}
		
		// Move title text
		titleOrigin.x = (periodLength-transitionLength-elapsedTime)/(periodLength - transitionLength)*(bounds.size.width+currentTitleWidth) - currentTitleWidth;

		[self setNeedsDisplay:YES];		
	}

}


//------------------------------------------------------------------------------
#pragma mark -
#pragma mark Configure Sheet
//------------------------------------------------------------------------------

- (BOOL)hasConfigureSheet {
    return NO;
}

- (NSWindow*)configureSheet {
    return nil;
}


//------------------------------------------------------------------------------
#pragma mark -
#pragma mark Helper
//------------------------------------------------------------------------------

- (void)startLoadingPageFromURL:(NSURL *)url {
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
	nextURL = [url copy];
}

- (void)webViewDidFinishLoading:(NSNotification *)notification {
	
	// the first time, show  the page immediately, otherwise it will switch when the timer fires
	if(currentImage == nil) {
		[self prepareImageFromView:[[[webView mainFrame] frameView] documentView]];
		[listOfWikiLinks removeAllObjects];
		[self getWikiLinksFromNodeTree:[[webView mainFrame] DOMDocument]];
		if(currentImage == nil) {
			[self switchToNextPage:self];
		}
	}
	else {
		// Subsequent times, run these on separate threads
		[NSThread detachNewThreadSelector:@selector(prepareImageFromViewOnNewThread:)
	                             toTarget:self
	                           withObject:[[[webView mainFrame] frameView] documentView]];

		[listOfWikiLinks removeAllObjects];
		[NSThread detachNewThreadSelector:@selector(getWikiLinksFromNodeTreeOnNewThread:)
	                             toTarget:self
	                           withObject:[[webView mainFrame] DOMDocument]];
	}
}

- (void)prepareImageFromView:(NSView *)view {
	NSRect viewRect = [view bounds];
	NSBitmapImageRep *imageRep = [view bitmapImageRepForCachingDisplayInRect:viewRect];
	[view cacheDisplayInRect:viewRect toBitmapImageRep:imageRep];
	NSSize repSize = [imageRep size];
	
	if(repSize.width > 0) {
		nextImage = [[NSImage alloc] initWithSize:viewRect.size];
		[nextImage addRepresentation:imageRep];
		[nextImage setScalesWhenResized:NO];
		
		nextFromRect = NSMakeRect(0, 0, [nextImage size].width, [nextImage size].height);
		float toHeight = [self bounds].size.height;
		if([nextImage size].height < toHeight) {
			toHeight = [nextImage size].height;
		}
		float toWidth = nextFromRect.size.width * (toHeight/nextFromRect.size.height);
		nextToRect = NSMakeRect(([self bounds].size.width-toWidth)/2,
							[self bounds].size.height-toHeight,
							toWidth,
							toHeight);

		nextFocalHeight = SSRandomFloatBetween(0,1.0);	
	}
}

- (void)switchToNextPage:(id)sender {
	NSImage *lastImage = currentImage;
	NSString *lastPageTitle = currentPageTitle;
	NSURL *lastURL = currentURL;
	
	currentImage = nextImage;
	currentPageTitle = nextPageTitle;
	currentURL = nextURL;
	currentFromRect = nextFromRect;
	currentToRect = nextToRect;
	currentFocalHeight = nextFocalHeight;
	
	titleOrigin = NSMakePoint([self bounds].size.width,[self bounds].size.height*0.05);
	currentTitleWidth = [currentPageTitle sizeWithAttributes:titleAttributes].width;
	float fontSize = [self bounds].size.height * 0.75;
	[titleAttributes setObject:[NSFont fontWithName:@"Lucida Grande" size:fontSize]
						forKey:NSFontAttributeName];
	
	
	[lastImage release];
	[lastPageTitle release];
	[lastURL release];
	
	// Mark this time as the start of the period
	periodStartTime = CFAbsoluteTimeGetCurrent();
	
	// Set the timer to load a new page
	switchTimer = [[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)periodLength
                                                         target:self
                                                       selector:@selector(switchToNextPage:)
                                                       userInfo:nil
                                                        repeats:NO] retain];
	
	// Start loading the next page
	if([listOfWikiLinks count]>0) {
		unsigned randomNum = SSRandomIntBetween(0,[listOfWikiLinks count]);
		[self startLoadingPageFromURL:[NSURL URLWithString:[listOfWikiLinks objectAtIndex:randomNum]]];
	}
	else {
		[self startLoadingPageFromURL:[NSURL URLWithString:startingURL]];
	}
}

- (void)getWikiLinksFromNodeTree:(DOMNode *)parent {
	DOMNodeList *nodeList = [parent childNodes];
	unsigned i, length = [nodeList length];
	NSString *hostName = [@"http://" stringByAppendingString:[nextURL host]];
	
	for (i = 0; i < length; i++) {
		DOMNode *node = [nodeList item:i];
		[self getWikiLinksFromNodeTree:node];
		DOMNamedNodeMap *attributes = [node attributes];
		unsigned a, attCount = [attributes length];
		
		if([[node nodeName] isCaseInsensitiveLike:@"a"]) {
			for (a = 0; a < attCount; a++) {
				DOMNode *att = [attributes item:a];
				if([[att nodeName] isCaseInsensitiveLike:@"href"]) {
					if([[att nodeValue] hasPrefix:@"/wiki/"]) { // get only links that start with wiki
						[listOfWikiLinks addObject:[hostName stringByAppendingString:[att nodeValue]]];
					}
				}
			}
		}
	}
	
	// Do some filtering
	NSEnumerator *enumerator = [listOfWikiLinks objectEnumerator]; 
	id link;
	while( link = [enumerator nextObject] ) {
		if([link rangeOfString:@"/wiki/Special"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Help"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Image"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Wiktionary"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Wikipedia:"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Main_Page"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Portal:"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/profit_organization"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/Charitable_organization"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
		if([link rangeOfString:@"/wiki/501"].location != NSNotFound) {
			[listOfWikiLinks removeObject:link];
		}
	}
}


//------------------------------------------------------------------------------
#pragma mark -
#pragma mark For Multiple Threads
//------------------------------------------------------------------------------

- (void)prepareImageFromViewOnNewThread:(NSView *)view {
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
	[self prepareImageFromView:view];
	[arp release];
}

- (void)getWikiLinksFromNodeTreeOnNewThread:(DOMNode *)parent {
	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
	[self getWikiLinksFromNodeTree:parent];
	[arp release];
}


//------------------------------------------------------------------------------
#pragma mark -
#pragma mark WebView delegate methods
//------------------------------------------------------------------------------

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
	if([title length] > 30) {
		// we want to remove the " - Wikipedia, the free encyclopedia" from the end of the title
		NSRange endRange = [title rangeOfString:@" - Wikipedia, the free encyclopedia"];
		nextPageTitle = [[title substringToIndex:endRange.location] retain];	}
}

@end
