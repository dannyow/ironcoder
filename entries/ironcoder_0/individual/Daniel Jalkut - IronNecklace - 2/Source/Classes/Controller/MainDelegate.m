#import <Quartz/Quartz.h>
#import "MainDelegate.h"
#import "RSUIElement.h"
#import "OverlayAnimationWindow.h"

@implementation MainDelegate

- (NSArray *)uiElements
{
	return [RSUIElement applicationElements];
}

- (void) awakeFromNib
{
	// Coerce the user into turning on UI access
	NSString* scriptPath = [[NSBundle mainBundle] pathForResource:@"CheckUIAccess" ofType:@"scpt"];
	if (scriptPath != nil)
	{
		NSURL* scriptURL = [NSURL fileURLWithPath:scriptPath];
		NSAppleScript* myScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
		if (myScript != nil)
		{
			[myScript executeAndReturnError:nil];
			[myScript release];
		}
	}

	// Set up the QCView for the main window
	[mWelcomeQCView loadCompositionFromFile:[[NSBundle mainBundle] pathForResource:@"IronCoder" ofType:@"qtz"]];
	[mWelcomeQCView setEraseColor:[NSColor clearColor]];
//	[mWelcomeQCView setValue:@"Happy Mardi Gras!" forInputKey:@"necklaceText"];		
//	[mWelcomeQCView setValue:[NSNumber numberWithFloat:0.09] forInputKey:@"beadFontSize"];		
	[mWelcomeQCView setMaxRenderingFrameRate:0];
	[mWelcomeQCView startRendering];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkForNewUIElement) userInfo:nil repeats:NO];	
}

- (void) checkForNewUIElement
{
	Point		pointAsCarbonPoint;

	// The current mouse position with origin at top left.
	GetMouse( &pointAsCarbonPoint );
	
	// Only ask for the UIElement under the mouse if has moved since the last check.
	if (pointAsCarbonPoint.h != _lastMousePoint.h || pointAsCarbonPoint.v != _lastMousePoint.v)
	{
	
		CGPoint				pointAsCGPoint;
		AXUIElementRef 		newElement		= NULL;

		pointAsCGPoint.x = pointAsCarbonPoint.h;
		pointAsCGPoint.y = pointAsCarbonPoint.v;

		// Ask Accessibility API for UI Element under the mouse
		// And update the display if a different UIElement
		AXUIElementRef systemWide = AXUIElementCreateSystemWide();
		if (AXUIElementCopyElementAtPosition(systemWide, pointAsCGPoint.x, pointAsCGPoint.y, &newElement ) == kAXErrorSuccess
			&& newElement)
		{
			if ((mTargetElement == nil) || ([mTargetElement representsNativeElement:newElement] == NO))
			{
				[mTargetElement release];
				mTargetElement = [[RSUIElement uiElementWithNativeRef:newElement] retain];
				[self updateNecklaceAtX:pointAsCGPoint.x andY:pointAsCGPoint.y];
			}
			CFRelease(newElement);
		}
		
		CFRelease(systemWide);
		
		_lastMousePoint = pointAsCarbonPoint;
	}
    
	// Let's meet up again soon...
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkForNewUIElement) userInfo:nil repeats:NO];
}

- (void) updateNecklaceAtX:(float)xAnchor andY:(float)yAnchor
{
//	if ([[mTargetElement roleDescription] isEqualToString:mLastDesc] == NO)
	{
		// Y anchor is relative to top origin, so we have to flip it 
		yAnchor = [[NSScreen mainScreen] frame].size.height - yAnchor;
		
		// Create a QCView appropriate for this transition
		const float viewWidth = 374.0;
		const float viewHeight = 489.0;
		float xOrigin = xAnchor - (viewWidth / 2);;
		float yOrigin = yAnchor - (viewHeight * .75);
		NSRect bigRect = NSMakeRect(xOrigin, yOrigin, viewWidth, viewHeight);
		QCView* necklaceView = [[[QCView alloc] initWithFrame:bigRect] autorelease];	
		[necklaceView loadCompositionFromFile:[[NSBundle mainBundle] pathForResource:@"Necklace" ofType:@"qtz"]];
		[necklaceView setFrameOrigin:NSMakePoint(0.0, 0.0)];
		[necklaceView setEraseColor:[NSColor clearColor]];
		[necklaceView setValue:[mTargetElement userVisibleName] forInputKey:@"necklaceText"];		
		[necklaceView setMaxRenderingFrameRate:0];
		
		// Create a borderless window with the QCView as its content
		OverlayAnimationWindow* newOverlay = [OverlayAnimationWindow overlayAnimationWindowForView:necklaceView];
		[newOverlay setFrame:bigRect display:NO];

		[necklaceView startRendering];
		
		// Always show the animation stuff above other windows
		[newOverlay setLevel:NSScreenSaverWindowLevel];
		[newOverlay orderFrontRegardless];

		// Close the old window if we had one
		[mOverlayWindow orderOut:self];
		[mOverlayWindow close];
		mOverlayWindow = newOverlay;
		[mLastDesc release];
		mLastDesc = [[mTargetElement userVisibleName] retain];
	}
}

@end
