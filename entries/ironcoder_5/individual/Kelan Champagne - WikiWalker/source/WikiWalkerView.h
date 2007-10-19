//
//  WikiWalkerView.h
//  WikiWalker
//
//  Created by Kelan Champagne on 3/31/07.
//  Copyright (c) 2007, Yeah Right Keller. All rights reserved.
//


#import <ScreenSaver/ScreenSaver.h>

#import <WebKit/WebKit.h>


@interface ComYeahRightKeller_WikiWalkerView : ScreenSaverView {
	NSImage *currentImage, *nextImage;
	NSRect currentFromRect, currentToRect, nextFromRect, nextToRect;
	float currentFocalHeight, nextFocalHeight;
	
	float periodLength, transitionLength;
	unsigned long int frameCounter;
	CFAbsoluteTime periodStartTime;
	
	NSString *currentPageTitle, *nextPageTitle;
	float currentTitleWidth;
	NSMutableDictionary *titleAttributes;
	NSPoint titleOrigin;
	
	
	WebView *webView;
	NSString *startingURL;
	NSURL *currentURL, *nextURL;
	NSMutableArray *listOfWikiLinks;
	
	NSTimer *switchTimer;
	
}

- (void)startLoadingPageFromURL:(NSURL *)url;

- (void)webViewDidFinishLoading:(NSNotification *)notification;

- (void)prepareImageFromView:(NSView *)view;
- (void)switchToNextPage:(id)sender;

- (void)getWikiLinksFromNodeTree:(DOMNode *)parent;

- (void)prepareImageFromViewOnNewThread:(NSView *)view;
- (void)getWikiLinksFromNodeTreeOnNewThread:(DOMNode *)parent;

@end
