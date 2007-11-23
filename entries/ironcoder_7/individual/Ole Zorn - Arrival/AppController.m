//
//  AppController.m
//  Arrival
//
//  Created by Ole Zorn on 14.11.07.
//  Copyright 2007 omz:software. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (id)init
{
	[super init];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:@"http://twitter.com/statuses/friends_timeline/791052.rss", @"feedURL", nil]];
	
	return self;
}

- (void)dealloc
{
	[rootLayer release];
	[feed release];
	[feedTimer release];
	[cycleTimer release];
	[letterLayers release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	textIndex = -1;
	[window center];
	[window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"background"]]];
	feedURL = [[[NSUserDefaults standardUserDefaults] stringForKey:@"feedURL"] retain];
	feedTitles = [NSMutableArray new];
	feed = [[PSFeed alloc] initWithURL:[NSURL URLWithString:feedURL]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedChanged:) name:PSFeedEntriesChangedNotification object:feed];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedChanged:) name:PSFeedRefreshingNotification object:feed];
	[feed refresh:NULL];
	feedTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(updateFeed:) userInfo:nil repeats:YES];
	cycleTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(showNextEntry:) userInfo:nil repeats:YES];
	[backButton setWantsLayer:YES];
	[forwardButton setWantsLayer:YES];
	[linkButton setWantsLayer:YES];
	[prefButton setWantsLayer:YES];
	CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
	[filter setDefaults];
	[filter setValue:[NSNumber numberWithFloat: 5.0] forKey:@"inputRadius"];
	[filter setName:@"glowFilter"];
	[[forwardButton layer] setFilters:[NSArray arrayWithObject:filter]];
	CABasicAnimation *glowAnimation = [CABasicAnimation animationWithKeyPath:@"filters.glowFilter.inputIntensity"];
	glowAnimation.fromValue = [NSNumber numberWithFloat:0.35];
	glowAnimation.toValue = [NSNumber numberWithFloat:1.00];
	glowAnimation.duration = 1.5;
	glowAnimation.repeatCount = 1e100f;
	glowAnimation.autoreverses = YES;
	glowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[[forwardButton layer] addAnimation:glowAnimation forKey:@"glowAnimation"];
	[[backButton layer] setFilters:[NSArray arrayWithObject:filter]];
	[[backButton layer] addAnimation:glowAnimation forKey:@"glowAnimation"];
	[[linkButton layer] setFilters:[NSArray arrayWithObject:filter]];
	[[linkButton layer] addAnimation:glowAnimation forKey:@"glowAnimation"];
	[[prefButton layer] setFilters:[NSArray arrayWithObject:filter]];
	[[prefButton layer] addAnimation:glowAnimation forKey:@"glowAnimation"];
	letterLayers = [NSMutableArray new];
	rootLayer = [[CALayer layer] retain];
	CGColorRef blackColor = CGColorCreateGenericGray(0, 1);
	rootLayer.backgroundColor = blackColor;
	CGColorRelease(blackColor);
	[view setLayer:rootLayer];
	[[window contentView] setWantsLayer:YES];
	[view setWantsLayer:YES];
	int i=0;
	float x = 3;
	float y = [view bounds].size.height - 103;
	for (; i<75; i++) {
		LetterLayer *l = [LetterLayer layer];
		l.anchorPoint = CGPointMake(0,0);
		l.position = CGPointMake(x,y);
		x += 50;
		if (x > [view bounds].size.width - 50) {
			x = 3;
			y -= 100;
		}
		[letterLayers addObject:l];
		[rootLayer addSublayer:l];
	}
	[self setInstantText:@" loading  feed"];
}

- (void)showNextEntry:(id)sender
{
	[cycleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:60]];
	if ([feedTitles count] == 0)
		[self setText:@"no feed entries"];
	else {
		textIndex++;
		if (textIndex > [feedTitles count] - 1)
			textIndex = 0;
		[self setText:[[feedTitles objectAtIndex:textIndex] valueForKey:@"title"]];
	}
}

- (IBAction)showPreviousEntry:(id)sender
{
	[cycleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:60]];
	if ([feedTitles count] == 0)
		[self setText:@"no feed entries"];
	else {
		textIndex--;
		if (textIndex < 0)
			textIndex = [feedTitles count] - 1;
		[self setText:[[feedTitles objectAtIndex:textIndex] valueForKey:@"title"]];
	}
}

- (IBAction)setFeedToMainFeed:(id)sender
{
	[feedTextField setStringValue:@"http://twitter.com/statuses/user_timeline/791052.rss"];
}

- (IBAction)setFeedToFriendsFeed:(id)sender
{
	[feedTextField setStringValue:@"http://twitter.com/statuses/friends_timeline/791052.rss"];
}

- (IBAction)setFeedToDaringFireball:(id)sender
{
	[feedTextField setStringValue:@"http://daringfireball.com/index.xml"];
}

- (IBAction)showArticle:(id)sender
{
	if (textIndex < 0)
		return;
	
	[[NSWorkspace sharedWorkspace] openURL:[[feedTitles objectAtIndex:textIndex] valueForKey:@"url"]];
}

- (void)updateFeed:(NSTimer *)timer
{
	[feed refresh:NULL];
}

- (void)feedChanged:(NSNotification *)notification
{
	[feedTitles removeAllObjects];
	
	NSSortDescriptor *feedSorter = [[[NSSortDescriptor alloc] initWithKey:@"datePublished" ascending:NO] autorelease];
	NSEnumerator *feedEnum = [feed entryEnumeratorSortedBy:[NSArray arrayWithObject:feedSorter]];
	PSEntry *currentEntry;
	while (currentEntry = [feedEnum nextObject]) {
		NSString *entryTitle = [currentEntry title];
		if ([entryTitle length] > 75) {
			int i;
			for (i=0; i<[entryTitle length]; i+=72) {
				int subEntryLength = 72;
				if (i + subEntryLength > [entryTitle length])
					subEntryLength = [entryTitle length] - i;
				NSString *subEntry = [entryTitle substringWithRange:NSMakeRange(i, subEntryLength)];
				if (i > 0)
					subEntry = [NSString stringWithFormat:@"...%@", subEntry];
				if (i + subEntryLength < [entryTitle length])
					subEntry = [subEntry stringByAppendingString:@"..."];
				NSDictionary *entryDict = [NSDictionary dictionaryWithObjectsAndKeys:subEntry, @"title", currentEntry.alternateURL, @"url", nil];
				[feedTitles addObject:entryDict];
			}
		} else {
			NSDictionary *entryDict = [NSDictionary dictionaryWithObjectsAndKeys:entryTitle, @"title", currentEntry.alternateURL, @"url", nil];
			[feedTitles addObject:entryDict];
		}
	}
	if ([feedTitles count] > 0) {
		[self showNextEntry:nil];
	}
	
}

- (void)setText:(NSString *)text
{
	NSString *lowerText = [text lowercaseString];
	int i = 0;
	
	for (LetterLayer *l in letterLayers) {
		NSString *currentLetter;
		if (i > [lowerText length] - 1)
			currentLetter = @" ";
		else
			currentLetter = [lowerText substringWithRange:NSMakeRange(i,1)];
		[l setTargetLetter:currentLetter];
		i++;
	}
}

- (void)setInstantText:(NSString *)text
{
	NSString *lowerText = [text lowercaseString];
	int i = 0;
	
	for (LetterLayer *l in letterLayers) {
		NSString *currentLetter;
		if (i > [lowerText length] - 1)
			currentLetter = @" ";
		else
			currentLetter = [lowerText substringWithRange:NSMakeRange(i,1)];
		[l setInstantLetter:currentLetter];
		i++;
	}
}

- (IBAction)showPrefs:(id)sender
{
	[prefWindow makeKeyAndOrderFront:self];
}

- (IBAction)closePrefs:(id)sender
{
	[prefWindow makeFirstResponder:[feedTextField nextResponder]];
	[prefWindow orderOut:self];
	NSString *newFeedURL = [feedTextField stringValue];
	if ([newFeedURL isEqual:feedURL])
		return;
	[newFeedURL retain];
	[feedURL release];
	feedURL = newFeedURL;
	[feed release];
	feed = [[PSFeed alloc] initWithURL:[NSURL URLWithString:feedURL]];
	textIndex = -1;
	[feedTitles removeAllObjects];
	[self updateFeed:nil];
}

@end
