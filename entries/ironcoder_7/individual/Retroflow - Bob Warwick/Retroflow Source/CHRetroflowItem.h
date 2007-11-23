#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "CHRetroflowController.h"
#import "EyeTunes.h"

@interface CHRetroflowItem : NSImageView {
	NSMutableArray *album;
	id controller;
	double itemDimension;
	int itemIndex;
	ETTrack *track;
}

- (id) initWithAlbumArray:(NSMutableArray *)iTunesAlbum dimension:(double)dimension inView:(id)parentView withController:(id)retroflowController;
- (NSArray *) album;
- (void) setItemIndex:(int)index;
- (ETTrack *) track;

@end
