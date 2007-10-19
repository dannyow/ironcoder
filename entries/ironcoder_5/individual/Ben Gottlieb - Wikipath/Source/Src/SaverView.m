//
//  SaverView.m
//  TestScreenSaver
//
//  Created by Ben Gottlieb on 3/31/07.
//  Copyright (c) 2007, Stand Alone, Inc.. All rights reserved.
//

#import "SaverView.h"

static NSString * const	kModuleName = @"com.standalone.wikiPathScreenSaver";

//================================================================================================================================

@implementation WikiPathScreenSaver_imageCell
- (id) initWithImage: (NSImage *) newImage frame: (NSRect) newBounds fromDir: (linkDirFrom) dir {
	if (self = [super init]) {
		fromDir = dir;
		image = [newImage retain];
		bounds = newBounds;
	}
	return self;
}

- (void) drawInParent {
	NSRect				copyBounds = bounds;
	NSBundle			*bundle = [NSBundle bundleForClass: [self class]];
	
	copyBounds = NSInsetRect(copyBounds, 2.0, 2.0);
	[image drawInRect: copyBounds fromRect: NSZeroRect operation: NSCompositeCopy fraction: 1.0];
	
	NSString				*path = nil;
	NSImage					*arrow = nil;
	
	switch (fromDir) {
		case linkDirFrom_Left: path = @"FromLeftArrow"; break;
		case linkDirFrom_Above: path = @"FromAboveArrow"; break;
		case linkDirFrom_Right: path = @"FromRightArrow"; break;
		case linkDirFrom_Below: path = @"FromBottomArrow"; break;
		case linkDirFrom_None: path = @"InitialBullsEye"; break;
	}

	if (path) {
		path = [bundle pathForImageResource: path];
		if (path) arrow = [[NSImage alloc] initWithContentsOfFile: path];
		if (arrow) [arrow drawInRect: bounds fromRect: NSZeroRect operation: NSCompositeSourceAtop fraction: 0.15];
		[arrow release];
	}
}

- (void) updateImageFromView: (NSView *) view proportionally: (BOOL) proportional {
	NSRect				takeBounds;
	
	if (proportional) {
		takeBounds = [view bounds]; 
		takeBounds.size.width -= 20.0;
		takeBounds.size.height -= 20.0;
		takeBounds.origin.y += 20.0;
	} else {
		takeBounds = NSMakeRect(0.0, 0.0, bounds.size.width, bounds.size.height);
	}
	NSData				*data = [view dataWithPDFInsideRect: takeBounds];
	
	[image release];
	image = [[NSImage alloc] initWithData: data];
}

@end

//================================================================================================================================

#define			kDrawSinglePathKey				@"WikiPathScreenSaver_DrawSinglePath"
#define			kSeedPageKey					@"WikiPathScreenSaver_SeedPage"
#define			kTileSizeKey					@"WikiPathScreenSaver_TileSize"
#define			kScreenClearIntervalKey			@"WikiPathScreenSaver_ScreenClearInterval"

#define			kRandomPageValue				@"##RANDOM##"
#define			kSmallSizeValue					@"size_small"
#define			kMediumSizeValue				@"size_medium"
#define			kLargeSizeValue					@"size_large"
#define			kToFitSizeValue					@"size_tofit"

//================================================================================================================================
#pragma mark INIT & DEALLOC
@implementation WikiPathScreenSaver_SaverView
- (id) initWithFrame: (NSRect) frame isPreview: (BOOL) isPreview
{
    self = [super initWithFrame: frame isPreview: isPreview];
    if (self)  {
		ScreenSaverDefaults				*defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
		
		// Register our default values
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			@"NO", kDrawSinglePathKey,
			@"Life", kSeedPageKey,
			kToFitSizeValue, kTileSizeKey,
			[NSNumber numberWithFloat: 30.0], kScreenClearIntervalKey,
		nil]];


		time_t				t;
		srand(time(&t));
		
		inPreview = isPreview;
		languagePrefix = @"en";
		
		currentURL = [[self generateInitialURL] retain];
			
		[self setFrameSize: frame.size];
        [self setAnimationTimeInterval: 0.1];
    }
    return self;
}

- (void) dealloc {
	if (webView) [webView stopLoading: self];
	[displayedPages release];
	[currentURL release];
	[imageCells release];
	[webView release];
	[currentImageCell release];
	if (cellArray) free(cellArray);
	[super dealloc];
}

//================================================================================================================================
#pragma mark SCREENSAVER
- (void) startAnimation
{
    [super startAnimation];
}

- (void) stopAnimation
{
    [super stopAnimation];
}

- (void) drawRect: (NSRect) invalidRect
{
	[super drawRect: invalidRect];
	
	NSEnumerator				*iter = [imageCells objectEnumerator];
	WikiPathScreenSaver_imageCell					*cell;
	
	while (cell = [iter nextObject]) {
		[cell drawInParent];
	}
	
}

- (void) animateOneFrame
{
	if (currentImageCell == nil) {	
		if (currentLinks && [currentLinks count] == 0) [self resetAllPaths];
		
		WikiPathScreenSaver_imageCell			*seedCell = [self cellAtPoint: currentFocusCell];
		linkDirFrom			dir = linkDirFrom_None;
		
		currentFocusCell = [self findNextCellPosition: currentFocusCell sourceDir: &dir];
		
		if (currentFocusCell.x == -1.0) return;
		
		WikiPathScreenSaver_imageCell			*newCell = [self generateCellFromSeed: seedCell atPoint: currentFocusCell fromDir: dir];
		[self setCell: newCell atPoint: currentFocusCell];
		[imageCells addObject: newCell];
	} else {
		if (currentImageCell && currentLoadStarted) [currentImageCell updateImageFromView: webView proportionally: YES];
	}
	
	[self setNeedsDisplay: YES];
}

- (void) setFrameSize: (NSSize) newSize {
	[super setFrameSize: newSize];
	[self resetAllPaths];
}

//================================================================================================================================
#pragma mark PRIVATE
- (void) resetAllPaths {
	NSSize						newSize = [self frame].size;
	ScreenSaverDefaults			*defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
	
	[imageCells release];
	imageCells = [[NSMutableArray alloc] init];
	if (cellArray) free(cellArray);
	pathTerminated = NO;
	
	[displayedPages release];
	displayedPages = [[NSMutableArray array] retain];
	
	NSString					*sizeValue = [defaults stringForKey: kTileSizeKey];
	
	if (inPreview) sizeValue = kSmallSizeValue;
	
	if ([sizeValue isEqualToString: kSmallSizeValue]) {
		squareSize = 100;
	} else
	if ([sizeValue isEqualToString: kMediumSizeValue]) {
		squareSize = 200;
	} else
	if ([sizeValue isEqualToString: kLargeSizeValue]) {
		squareSize = 400;
	} else {
		squareSize = 400;
		while (squareSize > 100) {
			if ((((int) newSize.width) % (int) squareSize == 0) && (((int) newSize.height) % (int) squareSize == 0)) break;  
			squareSize--;
		}
	}
	
	cellsAcross = floor(newSize.width / squareSize);
	cellsDown = floor(newSize.height / squareSize);
	cellArray = (WikiPathScreenSaver_imageCell **) calloc((int) (cellsAcross * cellsDown), sizeof(WikiPathScreenSaver_imageCell *));
	currentFocusCell = NSMakePoint(floor(cellsAcross / 2), floor(cellsDown / 2));
	leftOffset = (newSize.width - cellsAcross * squareSize) / 2;
	topOffset = (newSize.height - cellsDown * squareSize) / 2;
	
	[webView release];
	webView = [[WebView alloc] initWithFrame: NSMakeRect(0.0, 0.0, squareSize * 2, squareSize * 2)];
	[currentLinks release];
	currentLinks = nil;
	
	[nextResetTime release];
	nextResetTime = nil;
}

- (NSPoint) findNextCellPosition: (NSPoint) starter sourceDir: (linkDirFrom *) dir {
	const int						moves[] = {-1, 0,					0, -1,					1, 0,					0, 1};
	const linkDirFrom				dirs[] = {linkDirFrom_Right,		linkDirFrom_Above,		linkDirFrom_Left,		linkDirFrom_Below};
	int								i;
	WikiPathScreenSaver_imageCell	*cell;
	ScreenSaverDefaults				*defaults;
	
	if (starter.x == -1.0) {
		[self resetAllPaths];
		starter = currentFocusCell;
	}
	if ([self cellAtPoint: starter] == nil) return starter;
	
	*dir = linkDirFrom_None;
	if (nextResetTime) {
		if ([nextResetTime compare: [NSDate date]] == NSOrderedDescending) return NSMakePoint(-1.0, -1.0);			//not there yet
		
		[nextResetTime release];
		nextResetTime = nil;
		
		[self resetAllPaths];
	}
	
	if (pathTerminated || [imageCells count] == (cellsAcross * cellsDown)) {
		defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
		
		nextResetTime = [[NSDate dateWithTimeIntervalSinceNow: [defaults floatForKey: kScreenClearIntervalKey]] retain];
		[self terminatePath];
		return NSMakePoint(-1.0, -1.0);
	}
	
	int								initialDir = rand() % 4;
	for (i = 0; i < 4; i++) {
		int							moveDir = (initialDir + i) % 4;
		NSPoint						newPoint = starter;
		
		newPoint.x += moves[moveDir * 2];
		newPoint.y += moves[moveDir * 2 + 1];
		*dir = dirs[moveDir];
		
		if (newPoint.x >= cellsAcross || newPoint.y >= cellsDown || newPoint.x < 0 || newPoint.y < 0) continue;
		
		cell = [self cellAtPoint: newPoint];
		
		if (cell == nil) return newPoint;
	}
	
	defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
	
	if ([defaults boolForKey: kDrawSinglePathKey]) {
		[self terminatePath];
		return NSMakePoint(-1.0, -1.0);
	} 
	starter.x = rand() % (int) cellsAcross;
	starter.y = rand() % (int) cellsDown;
	*dir = linkDirFrom_None;
	
	return [self findNextCellPosition: starter sourceDir: dir];
}

- (WikiPathScreenSaver_imageCell *) cellAtPoint: (NSPoint) point {
	return cellArray[(int) (floor(point.x) + floor(point.y) * cellsAcross)];
}

- (void) setCell: (WikiPathScreenSaver_imageCell *) cell atPoint: (NSPoint) point {
	cellArray[(int) (floor(point.x) + floor(point.y) * cellsAcross)] = cell;
}

- (void) terminatePath {
	pathTerminated = YES;
}

- (WikiPathScreenSaver_imageCell *) generateCellFromSeed: (WikiPathScreenSaver_imageCell *) seed atPoint: (NSPoint) pt fromDir: (linkDirFrom) dir {
	WikiPathScreenSaver_imageCell			*cell = [[WikiPathScreenSaver_imageCell alloc] initWithImage: nil frame: NSMakeRect(leftOffset + pt.x * squareSize, topOffset + pt.y * squareSize, squareSize, squareSize) fromDir: dir];
	
	[currentImageCell release];
	
	currentImageCell = [cell retain];
	
	[webView setFrameLoadDelegate: self];
	if ([currentLinks count]) {
		[currentURL release];
		currentURL = [[currentLinks objectAtIndex: rand() % [currentLinks count]] retain];
		[displayedPages addObject: currentURL];
	} else 
		currentURL = [[self generateInitialURL] retain];
		
	[webView takeStringURLFrom: self];
	currentLoadStarted = NO;
	
	return cell;
}

- (NSString *) stringValue {
	return [[currentURL retain] autorelease];
}

- (void) collectCurrentLinks {
	int					i, numLinks;
	NSString			*link;
	
	[currentLinks release];
	numLinks = [[webView stringByEvaluatingJavaScriptFromString: @"document.links.length"] intValue];

	NSMutableArray		*links = [NSMutableArray arrayWithCapacity: numLinks];
	
	for (i = 0; i < numLinks; i++) {
		link = [webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"document.links[%d].href", i]];
		if ([self linkIsFollowable: link] && ![links containsObject: link]) [links addObject: link]; 
	}
	
	currentLinks = [links retain];
}

- (BOOL) linkIsFollowable: (NSString *) link {
	if ([link isEqualToString: currentURL]) return NO;
	if ([displayedPages containsObject: link]) return NO;
	
	link = [link substringFromIndex: 7];
	
	if ([[link pathExtension] length] > 0) return NO;				//this should filter out images, attachements, etc
	if ([link rangeOfString: @"#"].location != NSNotFound) return NO;				//this should filter out anchors
	if ([link rangeOfString: @":"].location != NSNotFound) return NO;				//this should filter out special pages like categories
	
	if ([link isEqualToString: @"en.wikipedia.org/wiki/Main_Page"] || 
		[link isEqualToString: @"en.wikipedia.org/wiki/Non-profit_organization"] || 
		[link isEqualToString: @"en.wikipedia.org/wiki/Charitable_organization"]) return NO;		//these links are on ALL pages, and should be skipped
		
	link = [link stringByDeletingLastPathComponent];
	
	if (![link isEqualToString: [NSString stringWithFormat: @"%@.wikipedia.org/wiki", languagePrefix]]) return NO;
	
	return YES;
}

- (NSString *) generateInitialURL {
	ScreenSaverDefaults			*defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
	NSString					*seedPage = [defaults stringForKey: kSeedPageKey];
	NSString					*url;
	
	if ([seedPage isEqualToString: kRandomPageValue]) 
		url = @"http://en.wikipedia.org/wiki/Special:Random";
	else {
		seedPage = [[seedPage componentsSeparatedByString: @" "] componentsJoinedByString: @"_"];
		url = [NSString stringWithFormat: @"http://en.wikipedia.org/wiki/%@", seedPage];
	}
	
	return url;
}

//================================================================================================================================
#pragma mark WEBVIEW DELEGATE
- (void) webView: (WebView *) sender didFinishLoadForFrame: (WebFrame *) frame {
	[currentImageCell updateImageFromView: webView proportionally: YES];
	if (frame == [sender mainFrame]) {				//the whole thing's done. Clear it out
		[currentImageCell release];
		
		currentImageCell = nil;
		
		[self collectCurrentLinks];
	}
	
	[self setNeedsDisplay: YES];
}

- (void) webView: (WebView *) sender didCommitLoadForFrame: (WebFrame *) frame {
	currentLoadStarted = YES;
	[currentImageCell updateImageFromView: webView proportionally: YES];
}

- (void) setInTestHarness: (BOOL) inHarness {
	inTestHarness = inHarness;
}


//================================================================================================================================
#pragma mark CONFIGURATION

- (BOOL) hasConfigureSheet
{
    return YES;
}

- (NSWindow *) configureSheet
{
    if (configSheet == nil) {
		if (![NSBundle loadNibNamed: @"ConfigureSheet" owner: self]) {
			NSLog(@"ConfigureSheet load failed");
			NSBeep();
		}
	}
	
	ScreenSaverDefaults			*defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
	NSString					*seedPage = [defaults stringForKey: kSeedPageKey];
	
	[deadEndMatrix selectCellWithTag: [defaults boolForKey: kDrawSinglePathKey] ? 0 : 1]; 
	if ([seedPage isEqualToString: kRandomPageValue]) {
		[initialTileMatrix selectCellWithTag: 1]; 
		[initialTileField setStringValue: @""];
		[initialTileField setEnabled: NO];
	} else {
		[initialTileMatrix selectCellWithTag: 0]; 
		[initialTileField setStringValue: seedPage];
		[initialTileField setEnabled: YES];
	}
	
	NSString					*sizeValue = [defaults stringForKey: kTileSizeKey];
	
	if ([sizeValue isEqualToString: kSmallSizeValue]) {
		[sizePopup selectItemWithTag: 0];
	} else
	if ([sizeValue isEqualToString: kMediumSizeValue]) {
		[sizePopup selectItemWithTag: 1];
	} else
	if ([sizeValue isEqualToString: kLargeSizeValue]) {
		[sizePopup selectItemWithTag: 2];
	} else {
		[sizePopup selectItemWithTag: 3];
	}
	
	[intervalSlider setFloatValue: [defaults floatForKey: kScreenClearIntervalKey]];

	return configSheet;
}

- (IBAction) cancelClick: (id) sender {
	[[NSApplication sharedApplication] endSheet: configSheet];
	if (inTestHarness) [configSheet close];
}

- (IBAction) okClick: (id) sender {
	ScreenSaverDefaults			*defaults = [ScreenSaverDefaults defaultsForModuleWithName: kModuleName];
	
	if ([initialTileMatrix selectedTag] == 0 && [[initialTileField stringValue] length] > 0) {
		[defaults setValue: [initialTileField stringValue] forKey: kSeedPageKey]; 
	} else
		[defaults setValue: kRandomPageValue forKey: kSeedPageKey];
	
	NSString					*sizeValues[] = {kSmallSizeValue, kMediumSizeValue, kLargeSizeValue, kToFitSizeValue};
	[defaults setValue: sizeValues[([sizePopup selectedTag])] forKey: kTileSizeKey];
	[defaults setBool: [deadEndMatrix selectedTag] forKey: kDrawSinglePathKey];
	[defaults setFloat: [intervalSlider floatValue] forKey: kScreenClearIntervalKey];
	
	[defaults synchronize];
	[[NSApplication sharedApplication] endSheet: configSheet];
	if (inTestHarness) [configSheet close];
	
	[currentURL release];
	
	currentURL = [[self generateInitialURL] retain];
	
	[self resetAllPaths];
	[self setNeedsDisplay: YES];
}

- (IBAction) initialTileChanged: (id) sender {
	if ([initialTileMatrix selectedTag] == 0) {					//specific page
		[initialTileField setEnabled: YES];
		[initialTileField selectText: self];
	} else
		[initialTileField setEnabled: NO];
}


@end
