//
//  AppDelegate.h
//  TimeRSSReader
//
//  Created by Jin Kim on 7/21/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject
{
	IBOutlet id oImageView;
	IBOutlet id oDrawer;
	IBOutlet id oFeedsArrayController;
	IBOutlet id oArticlesArrayController;	
	IBOutlet id oProgressIndicator;
	
	NSArray *mFeeds;
	NSMutableArray *mArticles;
	NSRect mPageRect;
	NSString *mPDFPath;
}

- (NSArray*)feeds;
- (NSMutableArray*)articles;

- (IBAction)chooseRandomArticle:(id)sender;
- (IBAction)changeFeed:(id)sender;
- (IBAction)changeArticle:(id)sender;
- (IBAction)readArticle:(id)sender;
- (IBAction)saveAs:(id)sender;

@end
