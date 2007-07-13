/* TimeController */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class TimeGraphView;

@interface TimeController : NSObject
{
	// Periodically update the UI
	NSTimer* mPeriodicUpdateTimer;
	
	// Track the amount of time since we last recorded 
	NSDate* mLastRecordedDate;

	// Which application is frontmost? It is this app that our accumulated time
	// will be credited to.
	NSString* mFrontApplication;	

	// NSDictionary accumulating our model data
	NSMutableDictionary* mTimeSpentPerProcess;
	
	// Interface
    IBOutlet TimeGraphView* timeView;
    IBOutlet NSWindow* ourWindow;

}

- (IBAction) openIronCoderHomePage:(id)sender;
- (IBAction) resetTimeStatistics:(id)sender;

@end
