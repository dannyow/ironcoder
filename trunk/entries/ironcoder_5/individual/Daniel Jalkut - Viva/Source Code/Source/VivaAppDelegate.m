//
//  VivaAppDelegate.m
//  VivaApp
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import "VivaAppDelegate.h"
#import "VivaWindow.h"
#import "ScreenSaverModules+Viva.h"

static NSString* kVivaTransparencyPreferenceKey = @"VivaTransparency";
static NSString* kVivaTilingPreferenceKey = @"VivaTiling";
static NSString* kVivaFirstLaunchPreferenceKey = @"FirstLaunch";
static NSString* kVivaTurnedOffSaverNamesPreferenceKey = @"TurnedOffSavers";

@implementation VivaAppDelegate

+ (void) initialize
{
	NSUserDefaults* sud = [NSUserDefaults standardUserDefaults];
	NSDictionary* defaultVals = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], kVivaTilingPreferenceKey,
																			[NSNumber numberWithFloat:1.0], kVivaTransparencyPreferenceKey,
																			[NSNumber numberWithBool:YES], kVivaFirstLaunchPreferenceKey,
																			[NSArray array], kVivaTurnedOffSaverNamesPreferenceKey,
																			nil];
	[sud registerDefaults:defaultVals];
}

- (void) awakeFromNib
{
	// Throttle the width of the checkbox column
	[oCheckboxColumn setMinWidth:20];
	[oCheckboxColumn setWidth:20];
	[oCheckboxColumn setMaxWidth:20];
	
	// Add a status item for our menu
	mStatusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	[mStatusItem setMenu:oStatusMenu];
	[mStatusItem setImage:[NSImage imageNamed:@"MenuIcon"]];
	[mStatusItem setHighlightMode:YES];
	
	// Start the "window" - taking up the whole screen
	NSRect vivaFrame = [[NSScreen mainScreen] frame];
	mVivaWindow = [[VivaWindow alloc] initWithContentRect:vivaFrame];
	
	float initialTransparency = [[NSUserDefaults standardUserDefaults] floatForKey:kVivaTransparencyPreferenceKey];
	[mVivaWindow setAlphaValue:initialTransparency];

	float initialTiling = [[NSUserDefaults standardUserDefaults] floatForKey:kVivaTilingPreferenceKey];
	if (initialTiling == 0)
	{
		initialTiling = 4;
	}
	[self setVivaTilingPreference:initialTiling];
	
	// Show prefs on first launch
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kVivaFirstLaunchPreferenceKey] == YES)
	{
		[oPrefsWindow makeKeyAndOrderFront:nil];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kVivaFirstLaunchPreferenceKey];
	}
	
	// Make sure prefs window keeps a high window level
	[oPrefsWindow setFloatingPanel:YES];
	[oPrefsWindow setLevel:NSScreenSaverWindowLevel];	
	[oPrefsWindow setBecomesKeyOnlyIfNeeded:YES];

	// Set the list of user-configured screensavers
	mOmittedScreensavers = [[[NSUserDefaults standardUserDefaults] objectForKey:kVivaTurnedOffSaverNamesPreferenceKey] mutableCopy];
	[mVivaWindow setScreensaverNames:[self userEnabledScreensaverNames]];	
	
	// Start animating!
	[self setVivaIsAnimating:YES];
}

- (NSString*) pauseResumeScreensaversMenuTitle
{
	if (mVivaIsAnimating == YES)
	{
		return NSLocalizedString(@"Pause Screensavers", nil);
	}
	else
	{
		return NSLocalizedString(@"Resume Screensavers", nil);	
	}
}

- (IBAction) toggleAnimation:(id)sender
{
#pragma unused (sender)
	[self setVivaIsAnimating:!mVivaIsAnimating];
}

//  vivaIsAnimating 
- (BOOL) vivaIsAnimating
{
    return mVivaIsAnimating;
}

- (void) setVivaIsAnimating: (BOOL) flag
{
	if (mVivaIsAnimating != flag)
	{
		mVivaIsAnimating = flag;
		
		if (flag == NO)
		{
			[mVivaWindow stopAnimating];
		}
		else
		{
			[mVivaWindow startAnimating];
		}
		
		[self willChangeValueForKey:@"pauseResumeScreensaversMenuTitle"];
		[self didChangeValueForKey:@"pauseResumeScreensaversMenuTitle"];
	}
}

//  vivaWindow 
- (VivaWindow *) vivaWindow
{
    return mVivaWindow; 
}

- (NSArray*) userEnabledScreensaverNames
{
	NSMutableArray* filteredNames = [[[ScreenSaverModules usableModuleNamesForViva] mutableCopy] autorelease];
	NSEnumerator* exclusionEnum = [mOmittedScreensavers objectEnumerator];
	NSString* thisOmission = nil;
	while (thisOmission = [exclusionEnum nextObject])
	{
		[filteredNames removeObject:thisOmission];
	}
	
	return [NSArray arrayWithArray:filteredNames];
}

- (NSMutableDictionary*) userConfiguredSaversInfo
{
	if (mUserSaverInfo == nil)
	{
		mUserSaverInfo = [[NSMutableDictionary dictionary] retain];
		NSArray* turnedOffNames = [[NSUserDefaults standardUserDefaults] objectForKey:kVivaTurnedOffSaverNamesPreferenceKey];
		NSArray* allNames = [ScreenSaverModules usableModuleNamesForViva];
		NSEnumerator* nameEnum = [allNames objectEnumerator];
		NSString* thisName = nil;
		while (thisName = [nameEnum nextObject])
		{
			NSNumber* enabledBool = [NSNumber numberWithBool:([turnedOffNames containsObject:thisName] == NO)];
			[mUserSaverInfo setObject:enabledBool forKey:thisName];
		}
	}

	return mUserSaverInfo;
}

//  vivaTransparency 
- (float) vivaTransparency
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:kVivaTransparencyPreferenceKey];
}

- (void) setVivaTransparency: (float) theVivaTransparency
{
	NSUserDefaults* sud = [NSUserDefaults standardUserDefaults];
	
	[sud setFloat:theVivaTransparency forKey:kVivaTransparencyPreferenceKey];
	[sud synchronize];

	[mVivaWindow setAlphaValue:theVivaTransparency];
}

//  vivaTilingPreference 
- (int) vivaTilingPreference
{
	int tilePref = [[NSUserDefaults standardUserDefaults] integerForKey:kVivaTilingPreferenceKey];
    return (tilePref == 0) ? 9 : tilePref;
}

- (void) setVivaTilingPreference: (int) theVivaTilingPreference
{
	NSUserDefaults* sud = [NSUserDefaults standardUserDefaults];
	
	[sud setInteger:theVivaTilingPreference forKey:kVivaTilingPreferenceKey];
	[sud synchronize];
	
	[mVivaWindow setVisibleScreensaverCount:theVivaTilingPreference];
	
}

// Table data source
//
//- (NSArray*) sortedNamesFromUserInfo:(NSDictionary*)userInfo
//{
//	NSArray* names = [userInfo valueForKey:@"name"];
//	return [names sortedArrayUsingSelector:@selector(compare:)];
//}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
#pragma unused (tableView)
	return [[ScreenSaverModules usableModuleNamesForViva] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
#pragma unused (tableView)
	NSArray* sortedNames = [[ScreenSaverModules usableModuleNamesForViva] sortedArrayUsingSelector:@selector(compare:)];
	NSString* thisKey = [sortedNames objectAtIndex:row];
	if ([[tableColumn identifier] isEqualToString:@"Selected"])
	{
		return [NSNumber numberWithBool:[mOmittedScreensavers containsObject:thisKey] == NO];
	}
	else if ([[tableColumn identifier] isEqualToString:@"SaverName"])
	{
		return thisKey;
	}
	else return nil;
}

/* optional - editing support
*/
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
#pragma unused (tableView)
	if ([[tableColumn identifier] isEqualToString:@"Selected"])
	{
		NSArray* sortedNames = [[ScreenSaverModules usableModuleNamesForViva] sortedArrayUsingSelector:@selector(compare:)];
		NSString* thisKey = [sortedNames objectAtIndex:row];
		if ([object boolValue] == YES)
		{
			[mOmittedScreensavers removeObject:thisKey];
		}
		else
		{
			[mOmittedScreensavers addObject:thisKey];
		}
		
		// Update the viva view (after a delay), so the user can make many changes in a row...
		if (mUpdateTimer == nil)
		{
			mUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(resetVivaWindow:) userInfo:nil repeats:NO] retain];
		}
		[mUpdateTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
					
		// Save to prefs
		[[NSUserDefaults standardUserDefaults] setObject:mOmittedScreensavers forKey:kVivaTurnedOffSaverNamesPreferenceKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void) resetVivaWindow:(NSTimer*)theTimer
{
	[mVivaWindow setScreensaverNames:[self userEnabledScreensaverNames]];
	
	if (theTimer == mUpdateTimer)
	{
		[mUpdateTimer invalidate];
		[mUpdateTimer release];
		mUpdateTimer = nil;
	}
}

- (IBAction) showPreferencesDialog:(id)sender
{
#pragma unused (sender)
	[oPrefsWindow makeKeyAndOrderFront:self];
}

@end
