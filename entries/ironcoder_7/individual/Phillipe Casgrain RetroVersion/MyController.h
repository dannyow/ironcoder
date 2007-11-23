#import <Cocoa/Cocoa.h>
#import "Revisions.h"

@interface MyController : NSObject 
{
	Revisions* revisions;
	NSTask* fetchLogTask;
	NSString* sourceURL;
	int curRevision;

	IBOutlet NSTextField* sourceURLText;
	IBOutlet NSProgressIndicator* progress;
	IBOutlet NSButton* fetchButton;
	IBOutlet NSTextField* statusText;
	IBOutlet NSSlider* revSelector;
	IBOutlet NSPathControl* path;
	IBOutlet NSScrollView* mainView;
	IBOutlet NSScrollView* altView;
	IBOutlet NSWindow* window;
}

- (IBAction) fetchLog: (id) sender;
- (IBAction) setRevision: (id) sender;

- (void) updateStatusWithRevision: (int) rev revisionDate: (NSDate*) date;
@end
