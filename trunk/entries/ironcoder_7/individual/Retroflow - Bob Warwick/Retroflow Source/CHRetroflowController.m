#import "CHRetroflowController.h"

@implementation CHRetroflowController

- (void) awakeFromNib {
	
	// Make sure iTunes is running
	[[NSWorkspace sharedWorkspace] launchApplication:@"iTunes"];
	
	// Register for notification so that we can quit if iTunes does
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(appQuit:) name:@"NSWorkspaceDidTerminateApplicationNotification" object:nil];
	
	srandom(time(NULL));
	
	showFlowers = 0;
	
	// Setup the track list
	[tracklist setRowHeight:28.0];
	
	// Setup the HUD View
	hudView = [[CHHUDView alloc] initWithFrame:NSMakeRect(([[retroflowWindow contentView] frame].size.width-240), 0, 240, [[retroflowWindow contentView] frame].size.height)];
	[[retroflowWindow contentView] addSubview:hudView];
	[trackscroll retain];
	[trackscroll removeFromSuperview];
	[[retroflowWindow contentView] addSubview:trackscroll];
	[trackscroll release];
	[recordView retain];
	[recordView removeFromSuperview];
	[[retroflowWindow contentView] addSubview:recordView];
	[recordView release];
	

	activeIndex = 0;
	
	// Add the aurora picture to an imageview the size of the contentview
	aurora = [[NSImage alloc] initWithContentsOfFile:@"/Library/Desktop Pictures/Nature/Aurora.jpg"];
	[auroraView setImage:aurora];
	[auroraView setImageScaling:NSScaleToFit];
	
	// Get a set of all iTunes Albums
	NSArray *iTunesTracks = [[[EyeTunes sharedInstance] libraryPlaylist] tracks];
	NSMutableDictionary *iTunesAlbums = [NSMutableDictionary dictionary];
	for (ETTrack *iTunesTrack in iTunesTracks) {
		if ([iTunesTrack album] != nil && [iTunesTrack artist] != nil) {
			if ([iTunesAlbums objectForKey:[NSString stringWithFormat:@"%@ - %@", [iTunesTrack artist], [iTunesTrack album]]] != nil) {
				[[iTunesAlbums objectForKey:[NSString stringWithFormat:@"%@ - %@", [iTunesTrack artist], [iTunesTrack album]]] addObject:iTunesTrack];
			} else {
				NSMutableArray *album = [NSMutableArray array];
				[iTunesAlbums setObject:album forKey:[NSString stringWithFormat:@"%@ - %@", [iTunesTrack artist], [iTunesTrack album]]];
				[[iTunesAlbums objectForKey:[NSString stringWithFormat:@"%@ - %@", [iTunesTrack artist], [iTunesTrack album]]] addObject:iTunesTrack];
			};
		};
	};
	[iTunesAlbums removeObjectForKey:@" - "]; // Remove blank album names
		
	// Sort that alphabetically into an array
	NSMutableArray *iTunesSortedAlbums = [NSMutableArray arrayWithArray:[iTunesAlbums allKeys]];
	[iTunesSortedAlbums sortUsingSelector:@selector(compareWithoutThe:)];
	
	
	// For all albums, initalize a CHRetroflowItem and add it to the albumCovers array
	double albumSize = 310;
	albumCovers = [[NSMutableArray alloc] init];
	for (NSString *albumName in iTunesSortedAlbums) {
		CHRetroflowItem *albumItem = [[CHRetroflowItem alloc] initWithAlbumArray:[iTunesAlbums objectForKey:albumName] dimension:albumSize inView:[retroflowWindow contentView] withController:self];
		[albumCovers addObject:albumItem];
		[albumItem release];
	};
	
	[[retroflowWindow contentView] setWantsLayer:YES];

	[self bringRetroflowItemAtIndexToFront:[NSNumber numberWithInt:0]];

	[tracklist setBackgroundColor:[NSColor clearColor]];

}

- (IBAction)appQuit:(NSNotification *)quitNotification {
	if ([[[quitNotification userInfo] objectForKey:@"NSApplicationName"] isEqualTo:@"iTunes"]) {
		[NSApp terminate:self];
	};
}

- (IBAction) bringRetroflowItemAtIndexToFront:(NSNumber *)itemIndex {
	[self bringRetroflowItemToFront:[albumCovers objectAtIndex:[itemIndex intValue]]];
}

- (IBAction) bringRetroflowItemToFront:(id)newFrontItem {

	[[hudView animator] setHidden:YES];
	[[trackscroll animator] setHidden:YES];
	[[auroraView animator] setImage:aurora];
	[[auroraView animator] setContentFilters:[NSArray array]];
	[recordView setHidden:YES];
	[albumLabel setHidden:NO];
	showFlowers = 0;

	int index = [albumCovers indexOfObject:newFrontItem];
	activeIndex = index;

	// Set all album items to their new positions
	index = index * -1;
	int j=0;
	for (j=0; j<[albumCovers count]; j++) {
		if (j < (activeIndex - 10) | j > (activeIndex + 10)) {
			[[albumCovers objectAtIndex:j] setHidden:YES];
		} else {
			[[albumCovers objectAtIndex:j] setItemIndex:index];
		};
		index++;
	};
	
	if ([[newFrontItem album] objectAtIndex:0] != nil && [[[newFrontItem album] objectAtIndex:0] artist] != nil) {
		[albumLabel setStringValue:[NSString stringWithFormat:@"%@ - %@", [[[newFrontItem album] objectAtIndex:0] artist], [[[newFrontItem album] objectAtIndex:0] album]]];
	} else {
		[albumLabel setStringValue:@""];
	};
}

- (int) count {
	return [albumCovers count];
}

- (IBAction) goLeft:(id)sender {
	int newActiveIndex = activeIndex - 1;
	[self bringRetroflowItemAtIndexToFront:[NSNumber numberWithInt:newActiveIndex]];
}

- (IBAction) goRight:(id)sender {
	int newActiveIndex = activeIndex + 1;
	[self bringRetroflowItemAtIndexToFront:[NSNumber numberWithInt:newActiveIndex]];
}

- (IBAction) selectAlbum:(id)sender {

	int i=0;
	for (i=0; i<[albumCovers count]; i++) {
		if (i != activeIndex) {
			[[[albumCovers objectAtIndex:i] animator] setHidden:YES];
		};
	};

	CHRetroflowItem *activeItem = [albumCovers objectAtIndex:activeIndex];
	double albumX = [auroraView frame].size.width - 220;
	double albumY = [auroraView frame].size.height - 220;
	[[activeItem animator] setFrame:NSMakeRect(albumX, albumY, 200, 200)];

	if ([hudView isHidden]) {
		[[EyeTunes sharedInstance] playTrack:[[albumCovers objectAtIndex:activeIndex] track]];
	} else {
		[[EyeTunes sharedInstance] playTrack:[[activeItem album] objectAtIndex:[tracklist selectedRow]]];
	};

	if ([hudView isHidden]) {
		[tracklist selectRow:0 byExtendingSelection:NO];
		[self performSelector:@selector(slideOutRecord) withObject:nil afterDelay:2.0];
	};
	[[hudView animator] setHidden:NO];
	[albumLabel setHidden:YES];
	[[trackscroll animator] setHidden:NO];
	[trackscroll becomeFirstResponder];
	[[auroraView animator] setImage:[activeItem image]];
	CIFilter *filter = [CIFilter filterWithName:@"CICrystallize"];
	[filter setDefaults];
	[filter setValue:[NSNumber numberWithFloat:40.0] forKey:@"inputRadius"];
	NSArray *filters = [NSArray arrayWithObject:filter];
	[[auroraView animator] setContentFilters:filters];
	
	showFlowers = 1;
	
	[tracklist setDataSource:activeItem];
}

- (void) slideOutRecord {
	[recordView setFrame:NSMakeRect([recordView frame].origin.x+100, [recordView frame].origin.y, [recordView frame].size.width, [recordView frame].size.height)];
	[[NSAnimationContext currentContext] setDuration:1.5];
	[recordView setHidden:NO];
	[[recordView animator] setFrame:NSMakeRect([recordView frame].origin.x-100, [recordView frame].origin.y, [recordView frame].size.width, [recordView frame].size.height)];

	[self performSelector:@selector(showHappyFlower:) withObject:happyFlower afterDelay:1.0];
	[self performSelector:@selector(showHappyFlower:) withObject:happyFlower2 afterDelay:2.0];
	[self performSelector:@selector(showHappyFlower:) withObject:happyFlower3 afterDelay:3.0];
}

- (void) showHappyFlower:(id)flowerToShow {

	if (showFlowers == 1) {
	
		int width = [[retroflowWindow contentView] frame].size.width;
		int height = [[retroflowWindow contentView] frame].size.height;

		double randomX = (random() % width) + 1;
		double randomX2 = (random() % width) + 1;
		double randomY = (random() % height) + 1;
		double randomY2 = (random() % height) + 1;
		double randomDimension = (random() % 200) + 200;
		double randomDelay = (random() % 2) + 4;
		
		[flowerToShow setFrame:NSMakeRect(randomX, randomY, randomDimension, randomDimension)];
		[[NSAnimationContext currentContext] setDuration:1.5];
		[[flowerToShow animator] setHidden:NO];
		[[NSAnimationContext currentContext] setDuration:5.25];
		[[flowerToShow animator] setFrame:NSMakeRect(randomX2, randomY2, randomDimension, randomDimension)];
		[self performSelector:@selector(hideHappyFlower:) withObject:flowerToShow afterDelay:3.0];
		[self performSelector:@selector(showHappyFlower:) withObject:flowerToShow afterDelay:randomDelay];
		
	}
}

- (void) hideHappyFlower:(id)flowerToHide {
	[[NSAnimationContext currentContext] setDuration:1.5];
	[[flowerToHide animator] setHidden:YES];
}

@end
