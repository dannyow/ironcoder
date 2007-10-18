/* SpaceController */

#import <Cocoa/Cocoa.h>
#import "SpaceView.h"

@interface SpaceController : NSObject
{
	IBOutlet NSSlider * spaceSlider;
	IBOutlet SpaceView * mainView;
	IBOutlet NSArrayController * planetController;
	IBOutlet NSDrawer * infoDrawer;
}

- (IBAction)panThroughSpace:(id)sender;
- (void)finishedScrollingAndLandedOn:(int)index;

@end
