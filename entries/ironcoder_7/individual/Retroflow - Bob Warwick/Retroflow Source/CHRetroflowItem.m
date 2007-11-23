#import "CHRetroflowItem.h"

@implementation CHRetroflowItem

- (id) initWithAlbumArray:(NSMutableArray *)iTunesAlbum dimension:(double)dimension inView:(id)parentView withController:(id)retroflowController  {
	
	// Call Super
	double myXPos = ([parentView frame].size.width/2) - (dimension/2);
	double myYPos = (([parentView frame].size.height/5)*2) - (dimension/2);
	self = [super initWithFrame:NSMakeRect(myXPos, myYPos, dimension, dimension)];
	
	// Setup instance variables
	track = [[iTunesAlbum objectAtIndex:0] retain];
	album = [iTunesAlbum retain];
	itemDimension = dimension;
	controller = [retroflowController retain];

	// Set a default album image
	NSImage *itemImage = [NSImage imageNamed:@"noCover"];
	[self setImage:itemImage];

	// Resize the artwork so we don't eat more memory than we need to
	[self performSelector:@selector(loadArtForTrack:) withObject:track afterDelay:0.0];
	
	// Add this view to the passed parent view
	[parentView addSubview:self];
	[self setHidden:YES];

	// And as always...
	return self;
}

- (void) loadArtForTrack:(id)theTrack {
	// Resize the passed image to dimension by dimension
	if ([[track artwork] count] > 0) {
		NSImage *theImage = [[track artwork] objectAtIndex:0];
		NSImage *resized = [[[NSImage alloc] initWithSize:NSMakeSize(itemDimension, itemDimension)] autorelease];
		[resized lockFocus];
		[theImage drawInRect:NSMakeRect(0, 0, itemDimension, itemDimension) fromRect:NSMakeRect(0, 0, [theImage size].width, [theImage size].height) operation:NSCompositeSourceOver fraction:1.0];
		[resized unlockFocus];
		[self setImage:resized];
	};
}

- (NSArray *) album {
	return album;
}

- (void) setItemIndex:(int)index {

	// Save the item index
	itemIndex = index;
			
	int zIndex = ((abs(index) * -1) + [controller count]);
	[self layer].zPosition = zIndex;
	if (index == 0) [self layer].zPosition = [controller count];
	
	double newDimension = itemDimension / (abs(index)+1);
	int xOffset = 0;
	if (index > 0) xOffset = itemDimension - newDimension;
	double selfOriginX = ([[self superview] frame].size.width/2) - (itemDimension/2) + (index * newDimension) + xOffset;
	double selfOriginY = (([[self superview] frame].size.height/5)*2) - (itemDimension/2);
	if ([self isHidden]) {
		[self setFrame:NSMakeRect(selfOriginX, selfOriginY, newDimension, newDimension)];
		[[self animator] setHidden:NO];
	} else {
		[[self animator] setFrame:NSMakeRect(selfOriginX, selfOriginY, newDimension, newDimension)];
	};
}

- (ETTrack *) track {
	return track;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [album count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {

	NSMutableDictionary *fontDictionary = [NSMutableDictionary dictionary];
	[fontDictionary setObject:[NSFont boldSystemFontOfSize:24.0] forKey:NSFontAttributeName];
	[fontDictionary setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];

	return [[[NSAttributedString alloc] initWithString:[[album objectAtIndex:rowIndex] name] attributes:fontDictionary] autorelease];
}

@end
