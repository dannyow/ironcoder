/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
	NSTimer *mTimer;
	NSSize mScreenSize;

	NSMutableArray *mWindows;
	NSMutableArray *mAnimatingWindows;
	NSMutableArray *mStaticWindows;
}

- (IBAction)startStop:(id)sender;
@end
