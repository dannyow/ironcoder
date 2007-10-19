/* PreferenceController */

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/NSPreferencePane.h>
#import "HotKey.h"

@interface PreferenceController : NSWindowController
{
	NSPreferencePane *prefPaneObject;
	
    IBOutlet id prefsView;
    IBOutlet id shortcutText;
    IBOutlet id sleepMinutes;
    IBOutlet id sleepSlider;
    IBOutlet id windowOpacity;
}

- (IBAction)changeShortcut:(id)sender;
- (IBAction)sleepTimeChanged:(id)sender;

- (NSArray*)hotKeyArray;
- (void)hotKeyArray: (NSArray*)hotKeyArray;
- (float)idleTime;
- (HotKey*)newHotKey;
- (void)showShortcut;

@end
