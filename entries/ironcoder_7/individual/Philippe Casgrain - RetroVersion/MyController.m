#import "MyController.h"
#import "Revision.h"

@implementation MyController

- (id) init 
{
	if (self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver: self 
						selector: @selector(finishedTask:) 
						name: NSTaskDidTerminateNotification 
						object: nil];
		curRevision = -1;
	}
	return self;
}

- (IBAction) fetchLog: (id) sender 
{
	sourceURL = [sourceURLText stringValue];
	[progress startAnimation: sender];
	[fetchButton setEnabled: NO];
	[statusText setStringValue: @"Fetching svn log..."];
	[statusText setHidden: NO];

	fetchLogTask = [[NSTask alloc] init];
	[fetchLogTask setLaunchPath: @"/usr/bin/svn"];
	[fetchLogTask setArguments: [NSArray arrayWithObjects: @"log", @"--xml", sourceURL, nil]];
	NSPipe* pipe = [[NSPipe alloc] init];
	[fetchLogTask setStandardOutput: pipe];
	[fetchLogTask launch];
}

// Iterate over all elements and fetch the annotated file for that revision
- (void) fetchAnnotatedFiles: (id) sender
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	int curRev = [[revisions elements] count];
	int originalRevision = -1;
	NSDate* originalDate = [NSDate dateWithTimeIntervalSinceNow: 0.0f];
	double delta = 1.0 / curRev;

	[progress setIndeterminate: NO];
	[progress setMinValue: 0.0];
	[progress setDoubleValue: 0.0];
	[progress setMaxValue: 1.0];
	[fetchButton setEnabled: NO];
	[statusText setHidden: NO];
	
	for (Revision* r in [revisions elements]) // Fast enumeration in Obj-C 2.0
	{
		// You'd think that you could use NSTask to do this, but noooo, 'svn cat' or 'svn annotate' don't play well with NSTask.
		// So I have to use system(). I could have used popen(), too, and not needed a temp file, but that's more work for
		// (arguably) not a whole lot in return.
		NSNumber* revToFetch = [r revision];
		[statusText setStringValue: [NSString stringWithFormat: @"Fetching revision %@...", revToFetch]];
		NSString* command = [NSString stringWithFormat: @"/usr/bin/svn cat %@ -r%@ > /tmp/retroversion.tmp", [revisions sourceURL], revToFetch];
		if (EXIT_SUCCESS == system([command UTF8String]))
		{
			[r setTextWithFile: @"/tmp/retroversion.tmp" deleting: YES];
			if ([revSelector intValue] == curRev)
			{
				[revSelector setEnabled: YES];
				[self setRevision: [NSNumber numberWithInt: curRev]];
				originalRevision = [[r revision] intValue];
				originalDate = [r commitDate];
			}
		}
		else
		{
			NSLog(@"Fetching revision index %& failed!", revToFetch);
		}
		curRev--;
		[progress incrementBy: delta];
	}
	
	[progress setIndeterminate: YES];
	[fetchButton setEnabled: YES];
	[self updateStatusWithRevision: originalRevision revisionDate: originalDate];
	[pool release];
}

- (void) finishedTask: (NSNotification*) aNotification 
{
	NSTask* task = [aNotification object];
	int status = [task terminationStatus];
	if ([task isEqual: fetchLogTask])
	{
		fetchLogTask = nil;
		[progress stopAnimation: nil];
		[fetchButton setEnabled: YES];
		[statusText setHidden: YES];
		if (status == 0)
		{
			NSLog(@"Fetch Log task succeeded.");
			NSPipe* pipe = [task standardOutput];
			NSFileHandle *file = [pipe fileHandleForReading];
			NSData *data = [file readDataToEndOfFile];
			NSError* err;
			NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData: data options:0 error:&err];
			revisions = [[Revisions alloc] initWithXMLDocument: doc sourceURL: sourceURL];
			sourceURL = nil;
			int numRevs = [[revisions elements] count];
			if (numRevs > 0)
			{
				[revSelector setMaxValue: numRevs];
				[revSelector setNumberOfTickMarks: numRevs];
				[revSelector setIntValue: numRevs];
				[NSThread detachNewThreadSelector:@selector(fetchAnnotatedFiles:) toTarget: self withObject: nil];
			}
		}
		else
		{
			NSLog(@"Fetch Log task failed.");
		}
	}
}

- (IBAction) setRevision: (id) sender
{
	int newRevision = [sender intValue];

	NSString* revText = nil;
	Revision* r = [[revisions elements] objectAtIndex: [[revisions elements] count] - newRevision];
	revText = [r annotatedListing];
	if (nil == revText)
	{
		revText = @"Please wait...";
	}
	
	if (curRevision == newRevision || curRevision < 0)
	{
		// Just need to set the text, no animation necessary
		NSTextView* textView = [mainView documentView];
		[textView setString: revText];
	}
	else
	{
		// Animate NSScrollViews out-and-in. Here are the steps:
		// Save position of main view
		NSRect mainViewRect = [mainView frame];
		float width = [window frame].size.width;
		NSRect offscreenMoveToRect = mainViewRect;
		NSRect offscreenMoveFromRect = mainViewRect;
		
		// Decide if we're animating towards left or right
		if (curRevision < newRevision)
		{
			offscreenMoveToRect.origin.x -= width;
			offscreenMoveFromRect.origin.x += width;
		}
		else
		{
			offscreenMoveToRect.origin.x += width;
			offscreenMoveFromRect.origin.x -= width;
		}
		
		// Main view becomes alt view
		NSScrollView* tmpView = mainView;
		mainView = altView;
		altView = tmpView;
		
		// Set text in (new) Main view
		[[mainView documentView] setString: revText];
		
		// Animate alt view out and hide
		[[altView animator] setFrame: offscreenMoveToRect];
		[[altView animator] setHidden: YES];
		
		// Relocate new main view appropriately (left or right) and show it
		[mainView setFrame: offscreenMoveFromRect];
		[mainView setHidden: NO];
		
		// Animate main view in 
		[[mainView animator] setFrame: mainViewRect];
		
	}

	// Set commit message as tooltip
	NSString* commitMessage = [r commitMessage];
	[mainView setToolTip: commitMessage];
	
	// Indicate which revision
	curRevision = newRevision;
	[self updateStatusWithRevision: [[r revision] intValue] revisionDate: [r commitDate]];
}

- (void) updateStatusWithRevision: (int) rev revisionDate: (NSDate*) date
{
	if (nil != date)
		[statusText setStringValue: [NSString stringWithFormat: @"Revision %d (%@)", rev, date]];
	else
		[statusText setStringValue: [NSString stringWithFormat: @"Revision %d", rev, date]];
}

// Useful delegate methods
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) theApplication
{
	return YES;
}

- (void) applicationDidFinishLaunching: (NSNotification*) aNotification
{
	[statusText setHidden: YES];
	[path setURL: [NSURL URLWithString: [sourceURLText stringValue]]];	
}

@end
