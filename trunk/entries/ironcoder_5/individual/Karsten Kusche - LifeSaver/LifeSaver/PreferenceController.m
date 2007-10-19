#import "PreferenceController.h"
#import "LifeSaverApp.h"
#import "ScreenSaverFramework.h"


@implementation PreferenceController

- (IBAction)sleepTimeChanged:(id)sender
{
	double sliderValue = [sleepSlider doubleValue];
	if ((int)sliderValue == 0)
	{
		[sleepMinutes setStringValue:@"Never"];
	}
	else
	{
		[sleepMinutes setStringValue:[NSString stringWithFormat:@"%i Minute%s",(int)sliderValue,(int)sliderValue != 1 ? "s":""]];
	}
}

- (void)showShortcut
{
	HotKey* hotKey = [NSApp hotKey];
	[shortcutText setStringValue:(hotKey == nil? @"no shortcut":[hotKey description])];
}

-(void)loadScreenSaverPrefs
{
	NSString* pathToPrefPaneBundle = @"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/ScreenEffects.prefPane";
	NSBundle *prefBundle = [NSBundle bundleWithPath: pathToPrefPaneBundle];
	Class prefPaneClass = [prefBundle principalClass];
	prefPaneObject = [[prefPaneClass alloc]
            initWithBundle:prefBundle];
//	NSLog(@"prefPane loaded... class = %@, prefPaneObject = %@",[prefPaneClass description],[prefPaneObject description]);
}

-(void)awakeFromNib
{
	[sleepSlider setDoubleValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"sleepTimer"]];
	[self sleepTimeChanged:nil];
	[self loadScreenSaverPrefs];
	[[self window] setWindowController:self];
}

- (IBAction)showWindow:(id)sender
{
//	NSUserDefaults* userDefs = [ScreenSaverDefaults defaultsForModuleWithName:@"com.apple.screensaver"];
//	[userDefs synchronize];
	ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForEngine];
	[defaults synchronize];
	//
	[self showShortcut];
	
	NSView *prefView;
	if ( [prefPaneObject loadMainView] ) {
		[prefPaneObject willSelect];
		prefView = [prefPaneObject mainView];
		
		[prefsView addSubview: prefView];
		NSRect subRect = [prefView frame];
		NSSize viewSize = [prefsView frame].size;
		subRect.origin.y = viewSize.height - subRect.size.height;
		[prefView setFrame:subRect];
		[prefPaneObject didSelect];
	} 
	else
	{
		NSLog(@"loadMainView failed -- handle error");
	}
	[[self window] makeKeyAndOrderFront:nil];
}

- (BOOL)windowShouldClose:(id)sender
{
	BOOL result = [prefPaneObject shouldUnselect] == NSUnselectNow;
//	NSLog(@"should the window close? %i",result);
	if (result)
	{
		[prefPaneObject willUnselect];
	}
	return result;
}

- (void)windowWillClose:(NSNotification *)aNotification
{
//	NSLog(@"window will close");
	[prefPaneObject didUnselect];
	ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForEngine];
	[defaults removeObjectForKey:@"previousModulName"];
	[defaults synchronize];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[NSApp hide:nil];
}

- (NSArray*)hotKeyArray
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"hotKey"];
}

- (void)hotKeyArray: (NSArray*)hotKeyArray
{
	if (hotKeyArray)
	{
		[[NSUserDefaults standardUserDefaults] setObject:hotKeyArray forKey:@"hotKey"];
	}	
	else
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hotKey"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (HotKey*)newHotKey
{
	EventRecord er;
	[shortcutText setStringValue:@"Enter new shortcut"];
	NSModalSession ms = [NSApp beginModalSessionForWindow:[self window]];
	do
	{
		[NSApp runModalSession:ms];
	} while (WaitNextEvent(keyDownMask | osMask,&er,0x14,0) == 0);
	[NSApp endModalSession:ms];
	return [HotKey fromEvent:er];
}

- (IBAction)changeShortcut:(id)sender
{
	[NSApp changeShortcut:sender];
}

- (float)idleTime
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:@"sleepTimer"];
}

@end
