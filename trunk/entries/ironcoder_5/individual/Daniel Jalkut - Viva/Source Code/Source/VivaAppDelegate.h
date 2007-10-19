//
//  VivaAppDelegate.h
//  VivaApp
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VivaWindow, VivaView;

@interface VivaAppDelegate : NSObject
{
	VivaWindow* mVivaWindow;

	IBOutlet NSPanel* oPrefsWindow;	
	IBOutlet NSTableColumn* oCheckboxColumn;
	
	// Status item
	NSStatusItem* mStatusItem;
	IBOutlet NSMenu* oStatusMenu;
	
	// Configuration for prefs
	NSMutableDictionary* mUserSaverInfo;
	NSMutableArray* mOmittedScreensavers;
	
	BOOL mVivaIsAnimating;
	
	NSTimer* mUpdateTimer;
}

- (IBAction) toggleAnimation:(id)sender;
- (BOOL) vivaIsAnimating;
- (void) setVivaIsAnimating: (BOOL) flag;

// Array of NSDictionary items with value a BOOL for enabled, and key the name
- (NSArray*) userEnabledScreensaverNames;
- (NSMutableDictionary*) userConfiguredSaversInfo;

- (float) vivaTransparency;
- (void) setVivaTransparency: (float) theVivaTransparency;

- (int) vivaTilingPreference;
- (void) setVivaTilingPreference: (int) theVivaTilingPreference;

- (IBAction) showPreferencesDialog:(id)sender;

@end
