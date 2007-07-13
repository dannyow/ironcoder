#import "AppController.h"

// Margin to leave to the right of a window
const int kPRMargin = 50;

#pragma mark -
#pragma mark Helper Functions
NSRect PRFrameOfWindow(AXUIElementRef window)
{
	NSRect frame;
	CFTypeRef val = nil;

	AXUIElementCopyAttributeValue(window, kAXPositionAttribute, &val);
	AXValueGetValue(val, kAXValueCGPointType, &frame.origin);
	[(id)val release];

	AXUIElementCopyAttributeValue(window, kAXSizeAttribute, &val);
	AXValueGetValue(val, kAXValueCGSizeType, &frame.size);
	[(id)val release];
	return frame;
}

CFTypeRef PRPositionOfFrame(NSRect frame)
{
	id val = (id)AXValueCreate(kAXValueCGPointType, &frame.origin);
	return [val autorelease];
}

BOOL PRTestBoolAttribute(AXUIElementRef element, CFStringRef attr)
{
	NSNumber *num = nil;
	AXUIElementCopyAttributeValue(element, attr, (CFTypeRef*)&num);
	BOOL val = [num boolValue];
	[num release];
	return val;
}

void PRSetWindowFrame(AXUIElementRef window, NSRect frame)
{
	// NOTE: Although it says "frame" in the name, this does not set
	// the size, because that's not necessary in this app.
	AXUIElementSetAttributeValue(window, kAXPositionAttribute, PRPositionOfFrame(frame));
}


@implementation AppController

#pragma mark Private Methods
// Credit goes to Apple for this method. It is lifted straight from UIElementInspector example.
- (void)p_checkForAccessibilityAPI
{
    if (!AXAPIEnabled())
    {
        int ret = NSRunAlertPanel (@"UI Element Inspector requires that the Accessibility API be enabled.  Would you like me to launch System Preferences so that you can turn on \"Enable access for assistive devices\".", @"", @"OK", @"Quit UI Element Inspector", @"Cancel");
        
        switch (ret)
        {
		case NSAlertDefaultReturn:
			[[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
			break;
                
		case NSAlertAlternateReturn:
            
			[NSApp terminate:self];
			return;
			break;
		case NSAlertOtherReturn: // just continue
		default:
			break;
        }
    }
}

- (NSMutableArray*)p_allWindows
{
	NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];

	NSMutableArray *windows = [NSMutableArray array];
	
	foreach (appdict, apps) 
	{
		if (appdict == [[NSWorkspace sharedWorkspace] activeApplication]) continue;
		
		pid_t pid = [[appdict objectForKey:@"NSApplicationProcessIdentifier"] intValue];

		NSArray *windowElements = nil;
		
		AXUIElementRef appref = AXUIElementCreateApplication(pid);

		if (PRTestBoolAttribute(appref, kAXHiddenAttribute)) continue;

		AXUIElementCopyAttributeValue(appref, kAXWindowsAttribute, (CFTypeRef*)&windowElements);

		if (windowElements == nil) continue;

		foreach (w, windowElements)
		{
			AXUIElementRef windowElement = (AXUIElementRef)w;
			if (PRTestBoolAttribute(windowElement, kAXMinimizedAttribute)) continue;
			
			Boolean writable;
			AXUIElementIsAttributeSettable((AXUIElementRef)windowElement, kAXPositionAttribute, &writable);

			if (!writable) continue;
			
			NSRect frame = PRFrameOfWindow((AXUIElementRef)windowElement);

			NSMutableDictionary *d = [NSMutableDictionary dictionary];
			[d sv:w fk:@"windowElement"];
			[d sv:[NSValue valueWithRect:frame] fk:@"origFrame"];

			[windows addObject:d];
		}

		[windowElements release];
	}

	return windows;
}

- (void)p_retireWindowToWaitQueue
{
	if ([mAnimatingWindows count] == 0) return;
	[mStaticWindows addObject:[mAnimatingWindows objectAtIndex:0]];
	[mAnimatingWindows removeObjectAtIndex:0];
}

- (void)p_advanceWindowToAnimationQueue
{
	if ([mStaticWindows count] == 0) return;
	[mAnimatingWindows addObject:[mStaticWindows objectAtIndex:0]];
	[mStaticWindows removeObjectAtIndex:0];
}

- (void)p_animate
{
	NSMutableArray *copy = [mAnimatingWindows copy];
	BOOL bringAnother = YES;
	
	foreach (d, copy)
	{
		if ([mStaticWindows containsObject:d]) continue;
		
		AXUIElementRef window = (AXUIElementRef)[d v:@"windowElement"];
		NSRect frame = PRFrameOfWindow(window);

		frame.origin.x -= 1;

		// Should we bring in the next window?
		if (NSMaxX(frame) + kPRMargin < mScreenSize.width)
			bringAnother = YES;
		else
			bringAnother = NO;
		
		// Moved off the screen to the left
		if (NSMaxX(frame) <= 0)
		{
			frame.origin.x = mScreenSize.width-1;
			[self p_retireWindowToWaitQueue];
		}
		PRSetWindowFrame(window, frame);
	}

	if (bringAnother) {
		[self p_advanceWindowToAnimationQueue];
	}
	
	[copy release];
}

- (void)p_start
{
	if (mWindows != nil) [mWindows release];
	mWindows = [[self p_allWindows] retain];

	foreach (d, mWindows) 
	{
		AXUIElementRef window = (AXUIElementRef)[d v:@"windowElement"];
		NSRect frame = PRFrameOfWindow(window);
		frame.origin.x = mScreenSize.width-1;
		PRSetWindowFrame(window, frame);
	}

	[mStaticWindows addObjectsFromArray:mWindows];
	[mStaticWindows removeObjectAtIndex:0];

	[mAnimatingWindows addObject:[mWindows objectAtIndex:0]];
	
	mTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
											  target:self
											selector:@selector(p_animate)
											userInfo:nil
											 repeats:YES];
}

- (void)p_stop
{
	[mTimer invalidate];
	mTimer = nil;

	foreach (d, mWindows)
	{
		AXUIElementRef window = (AXUIElementRef)[d v:@"windowElement"];
		NSRect frame = [[d v:@"origFrame"] rectValue];
		PRSetWindowFrame(window, frame);
	}
	
	[mWindows release];
	mWindows = nil;

	[mAnimatingWindows removeAllObjects];
	[mStaticWindows removeAllObjects];
}

- (IBAction)startStop:(id)sender
{
	if ([[sender title] isEqual:@"Start"])
	{
		[self p_start];
		[sender setTitle:@"Stop"];
	}
	else
	{
		[self p_stop];
		[sender setTitle:@"Start"];
	}
}

#pragma mark Public Methods
- (id)init
{
	self = [super init];
	mAnimatingWindows = [[NSMutableArray alloc] init];
	mStaticWindows = [[NSMutableArray alloc] init];
	return self;
}

- (void)awakeFromNib
{
	[self p_checkForAccessibilityAPI];
	mScreenSize = [[NSScreen mainScreen] frame].size;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self p_stop];
}

@end
