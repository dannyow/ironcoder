//
//  FFM.m
//  FFMinator
//
//  Created by Tom Harrington on 3/4/06;11:04 AM.
//  Copyright 2006 Atomic Bird LLC. All rights reserved.
//

#import "FFM.h"
#import "FFMinatorGlobal.h"

@implementation FFM

- (void)awakeFromNib
{
	NSLog(@"FFMinatorTool starting up...");
	
	// Set up monitoring as in UIElementInspector
    _systemWideElement = AXUIElementCreateSystemWide();
	
	[self updateCurrentUIElement:nil];
	
	currentUIAppearanceTime = time(NULL);
	raisedCurrentElement = NO;
	skipNextRaise = NO;
	// Whenever a new AXUIElementRef is found, walk up its inheritance hierarchy until an AXWindow is found.
	// Wait N secons (to be configured in system prefs)
	// Then perform AXRaise on it.
	
	// possible addition: switch to currently running app under mouse in dock.  optionally hide other apps when doing so.
	// also: move windows given a modifier
	
	// Load delay time from prefs
	NSNumber *delayValue = (NSNumber *)CFPreferencesCopyValue((CFStringRef)preferencesDelayKey,
															  (CFStringRef)preferencesAppName,
															  kCFPreferencesCurrentUser,
															  kCFPreferencesAnyHost);
	if (delayValue != nil) {
		focusRaiseDelay = [delayValue intValue];
	} else {
		focusRaiseDelay = 1;
	}
	// Load "show me" flag from prefs
	NSNumber *showMeYourBitsValue = (NSNumber *)CFPreferencesCopyValue((CFStringRef)preferencesShowMeYourBitsKey,
																	   (CFStringRef)preferencesAppName,
																	   kCFPreferencesCurrentUser,
																	   kCFPreferencesAnyHost);
	if (showMeYourBitsValue != nil) {
		showMeYourBits = [showMeYourBitsValue boolValue];
	} else {
		showMeYourBits = NO;
	}
	// and listen for prefs changes
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(newDelayTime:)
															name:newDelayTimeNotification
														  object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(newShowMeYourBitsFlag:)
															name:newShowMeYourBitsFlagNotification
														  object:nil];
}

- (void)newShowMeYourBitsFlag:(NSNotification *)note
{
	NSDictionary *userInfo = [note userInfo];
	NSNumber *newShowMeFlag = [userInfo objectForKey:newShowMeYourBitsFlagKey];
	showMeYourBits = [newShowMeFlag boolValue];
}

- (void)newDelayTime:(NSNotification *)note
{
	NSDictionary *userInfo = [note userInfo];
	NSNumber *newDelayTime = [userInfo objectForKey:newDelayTimeKey];
	focusRaiseDelay = [newDelayTime intValue];
	NSLog(@"New delay time: %d", focusRaiseDelay);
}

- (void)setCurrentUIElement:(AXUIElementRef)uiElement
{
    if (uiElement)
        CFRetain( uiElement );
    
    if (_currentUIElementRef)
        CFRelease( _currentUIElementRef );
	
	_currentUIElementRef = uiElement;
	raisedCurrentElement = NO;
}

- (AXUIElementRef)currentUIElement
{
    return _currentUIElementRef;
}

- (AXUIElementRef)windowForElement:(AXUIElementRef)element
{
	NSString *roleString = nil;
	AXError attributeCopyError;
	
	if (element == nil)
		return nil;
	attributeCopyError = AXUIElementCopyAttributeValue(element,
													   kAXRoleAttribute,
													   (CFTypeRef *)&roleString);
//	NSLog(@"Role: %@", roleString);
	if (attributeCopyError != kAXErrorSuccess)
		return nil;
	
	if ([roleString isEqualToString:(NSString *)kAXWindowRole]) {
		// Got the window
		return element;
	} else {
		// Didn't get the window, so get the parent and try again
		AXUIElementRef parent;
		attributeCopyError = AXUIElementCopyAttributeValue(element,
														   kAXParentAttribute,
														   (CFTypeRef *)&parent);
		if (attributeCopyError != kAXErrorSuccess)
			return nil;
		return [self windowForElement:parent];
	}
}

- (AXUIElementRef)applicationForElement:(AXUIElementRef)element
{
	NSString *roleString = nil;
	AXError attributeCopyError;
	
	if (element == nil)
		return nil;
	attributeCopyError = AXUIElementCopyAttributeValue(element,
													   kAXRoleAttribute,
													   (CFTypeRef *)&roleString);
//	NSLog(@"Role (2): %@", roleString);
	if (attributeCopyError != kAXErrorSuccess)
		return nil;
	
	if ([roleString isEqualToString:(NSString *)kAXApplicationRole]) {
		// Got the window
		return element;
	} else {
		// Didn't get the window, so get the parent and try again
		AXUIElementRef parent;
		attributeCopyError = AXUIElementCopyAttributeValue(element,
														   kAXParentAttribute,
														   (CFTypeRef *)&parent);
		if (attributeCopyError != kAXErrorSuccess)
			return nil;
		return [self applicationForElement:parent];
	}
}

+ (id)valueOfExistingAttribute:(CFStringRef)attribute ofUIElement:(AXUIElementRef)element
{
    id result = nil;
    NSArray *attrNames;
    
    if (AXUIElementCopyAttributeNames(element, (CFArrayRef *)&attrNames) == kAXErrorSuccess) {
        if ( [attrNames indexOfObject:(NSString *)attribute] != NSNotFound
			 &&
			 AXUIElementCopyAttributeValue(element, attribute, (CFTypeRef *)&result) == kAXErrorSuccess
			 ) {
            [result autorelease];
        }
        [attrNames release];
    }
    return result;
}

- (void)fadeWindow:(id)unused
{
	float currentAlpha = [toolWindow alphaValue];
	if (currentAlpha > 0.0) {
		currentAlpha -= 0.1;
		if (currentAlpha < 0.0)
			currentAlpha = 0.0;
		[toolWindow setAlphaValue:currentAlpha];
		[self performSelector:@selector(fadeWindow:)
				   withObject:nil
				   afterDelay:0.05];
	}
}

- (void)raiseElementWindow:(AXUIElementRef)element
{
	if (CFGetTypeID(element) != AXUIElementGetTypeID()) {
		return;
	}
	AXUIElementRef elementWindow;
	AXError attributeCopyError;

	NSString *roleString = nil;
	
	if (element == nil)
		return;
	attributeCopyError = AXUIElementCopyAttributeValue(element,
													   kAXRoleAttribute,
													   (CFTypeRef *)&roleString);
//	NSLog(@"Role (0): %@", roleString);
	if (attributeCopyError != kAXErrorSuccess)
		return;

	elementWindow = [self windowForElement:element];
	attributeCopyError = AXUIElementPerformAction(elementWindow,
												  kAXRaiseAction);
	AXUIElementRef elementApplication;
	if (elementWindow != nil)
		elementApplication = [self applicationForElement:elementWindow];
	else
		elementApplication = [self applicationForElement:element];
	attributeCopyError = AXUIElementPerformAction(elementApplication,
												  kAXRaiseAction);
	
	NSString *applicationName = nil;
	/*
	attributeCopyError = AXUIElementCopyAttributeValue(elementApplication,
													   kAXTitleAttribute,
													   (CFTypeRef *)&applicationName);
	if (attributeCopyError == kAXErrorSuccess)
		NSLog(@"App: %@", applicationName);
	else
		NSLog(@"error getting app name");
	*/
	applicationName = [FFM valueOfExistingAttribute:kAXTitleAttribute ofUIElement:elementApplication];
//	NSLog(@"App: %@", applicationName);
	if ([roleString isEqualToString:(NSString *)kAXDockItemRole]) {
		// handle dock items: if the app is running, bring it forward
//		NSLog(@"Dock item");
		CFBooleanRef running = kCFBooleanFalse;
		attributeCopyError = AXUIElementCopyAttributeValue(element,
														   kAXIsApplicationRunningAttribute,
														   (CFTypeRef *)&running);
		if ((attributeCopyError == kAXErrorSuccess) && CFEqual(running,kCFBooleanTrue)) {
			attributeCopyError = AXUIElementPerformAction(element,
														  kAXPressAction);
		}
	} else if ([roleString isEqualToString:(NSString *)kAXButtonRole] && [applicationName isEqualToString:@"Dock"]) {
		// handle command-tab icons
		// command-tab icons are a special case b/c as soon as the command-tab bar disappears, the
		// pointer may be over an entirely different app.  To try and prevent spurious switching at
		// that point, pretend we already raised the current element.
		skipNextRaise = YES;
		attributeCopyError = AXUIElementPerformAction(element,
													  kAXPressAction);
	} else {
		// handle all other UI elements by bringing them to the front
		
		AXUIElementSetAttributeValue(elementWindow,
									 kAXFocusedAttribute,
									 kCFBooleanTrue);

		AXUIElementSetAttributeValue(elementApplication,
									 kAXFrontmostAttribute,
									 kCFBooleanTrue);
	}

	if (showMeYourBits) {
		NSRect targetRect = [toolWindow frame];
		Point		pointAsCarbonPoint;
		// GetMouse gives us the origin at top left
		GetMouse( &pointAsCarbonPoint );
		// NSWindow frame coords have origin at bottom left
		NSScreen *mainScreen = [NSScreen mainScreen];
		targetRect.origin.y = [mainScreen frame].size.height - pointAsCarbonPoint.v;
		targetRect.origin.x = pointAsCarbonPoint.h;
		[toolWindow center];
		[toolWindow rotateImage];
		[toolWindow setAlphaValue:1.0];
		[toolWindow orderFront:nil];
		
		[toolWindow setFloatingPanel:YES];
		[toolWindow setHidesOnDeactivate:NO];
		[toolWindow setWorksWhenModal:YES];
		[toolWindow setOpaque:NO];
		[toolWindow setCanHide:NO];
		[toolWindow setLevel:NSStatusWindowLevel];
		
		/*	if ([toolWindow isVisible])
			NSLog(@"visible");
		else
			NSLog(@"not visible");
		*/
		[toolWindow setFrame:targetRect display:YES animate:YES];
		//	[toolWindow orderOut:nil];
		[self fadeWindow:nil];
	}
}

- (void)updateCurrentUIElement:(id)unused
{
	Point		pointAsCarbonPoint;
	
//	NSLog(@"updating ui element");
	// The current mouse position with origin at top left.
	GetMouse( &pointAsCarbonPoint );

	// Find UI element at point (always)
	// if same UI element as N ms ago, raise it.
	CGPoint				pointAsCGPoint;
	AXUIElementRef 		newElement		= NULL;
	
	pointAsCGPoint.x = pointAsCarbonPoint.h;
	pointAsCGPoint.y = pointAsCarbonPoint.v;
	
	if ((AXUIElementCopyElementAtPosition( _systemWideElement, pointAsCGPoint.x, pointAsCGPoint.y, &newElement ) == kAXErrorSuccess)
		&& newElement) {
		if (([self currentUIElement]) && CFEqual( [self currentUIElement], newElement )) {
			// if new element is the same as the last one, check how long since we first saw it
			time_t currentTime = time(NULL);
			if ((!raisedCurrentElement) && (currentTime - currentUIAppearanceTime) >= focusRaiseDelay) {
				if (skipNextRaise)
					skipNextRaise = NO;
				else
					[self raiseElementWindow:newElement];
				raisedCurrentElement = YES;
			}
		} else {
			// if new element is not the same as the last one, record the current time.
			currentUIAppearanceTime = time(NULL);
			[self setCurrentUIElement:newElement];
		}
	}

	[self performSelector:@selector(updateCurrentUIElement:)
			   withObject:nil
			   afterDelay:0.1];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	NSLog(@"FFMinatorTool exiting...");
}
@end
