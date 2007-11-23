#import "CHStringExtensions.h"
#import <Cocoa/Cocoa.h>
#import "EyeTunes.h"
#import <QuartzCore/QuartzCore.h>
#import "CHRetroflowItem.h"
#import "CHHUDView.h"

@interface CHRetroflowController : NSObject {
	id spacer;
	int activeIndex;
	NSMutableArray *albumCovers;
	IBOutlet id albumLabel;
	NSImage *aurora;
	IBOutlet id auroraView;
	IBOutlet id happyFlower;
	IBOutlet id happyFlower2;
	IBOutlet id happyFlower3;
	IBOutlet id happyFlower4;
	CHHUDView *hudView;
	IBOutlet id recordView;
	IBOutlet id retroflowWindow;
	int showFlowers;
	IBOutlet id tracklist;
	IBOutlet id trackscroll;
}

- (IBAction)appQuit:(NSNotification *)quitNotification;
- (IBAction) bringRetroflowItemAtIndexToFront:(NSNumber *)itemIndex;
- (IBAction) bringRetroflowItemToFront:(id)newFrontItem;
- (int) count;
- (IBAction) goLeft:(id)sender;
- (IBAction) goRight:(id)sender;
- (void) hideHappyFlower:(id)flowerToHide;
- (IBAction) selectAlbum:(id)sender;
- (void) showHappyFlower:(id)flowerToShow;
- (void) slideOutRecord;

@end