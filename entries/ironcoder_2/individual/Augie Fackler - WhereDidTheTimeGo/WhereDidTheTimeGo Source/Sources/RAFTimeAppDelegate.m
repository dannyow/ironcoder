//
//  RAFTimeAppDelegate.m
//  WhereDidTheTimeGo
//
//  Created by Augie Fackler on 7/22/06.
//  Copyright 2006 R. August Fackler. All rights reserved.
//

#import "RAFTimeAppDelegate.h"
#import "RAFPreferencesWindowController.h"
#import <PDFKit/PDFKit.h>

@implementation RAFTimeAppDelegate

RAFTimeAppDelegate *sharedInstance = nil;
BOOL firstDisplay = NO;

- (void)awakeFromNib
{
	sharedInstance = self;
}

/**
 * @brief initializes NSUserDefaults
 *
 * This sets up NSUserDefaults with our default preference values early
 * on so that when the nib binds to stuff on the NSUserDefaultsController
 * we don't just get NSNull values.
 * This is called in main() but that feels dirty, and it seems there's a better place for this.
 */
+ (void)setupDefaults
{
    NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
    NSDictionary *initialValuesDict;
    NSArray *resettableUserDefaultsKeys;
    
    // load the default values for the user defaults
    userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"DefaultPrefs" 
														   ofType:@"plist"];
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    

    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
    
    resettableUserDefaultsKeys=[NSArray arrayWithObjects:REDRAW_INTERVAL_PREFS_KEY,SAMPLE_INTERVAL_PREFS_KEY,WINDOW_TRANSPARENCY_PREFS_KEY,nil];
    initialValuesDict=[userDefaultsValuesDict dictionaryWithValuesForKeys:resettableUserDefaultsKeys];
    
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDict];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[RAFTimeAppDelegate setupDefaults];
	NSNumber			*redrawInterval;
	NSNumber			*sampleInterval;
	NSNumber			*windowTransparency;

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[self bind:@"windowTransparency" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.WindowTransparency" options:nil];
	[self bind:@"sampleInterval" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.SampleInterval" options:nil];
	[self bind:@"redrawInterval" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.RedrawInterval" options:nil];
	NSAssert(userDefaults != nil, @"userDefaults should never be nil!");
	// if appCounts was nil, make the dict manually
	if (!(appCounts = [[userDefaults objectForKey:APP_COUNT_PREFS_KEY] mutableCopy])) {
		appCounts = [[NSMutableDictionary alloc] init];
		NSNumber *tmpSamples = [NSNumber numberWithInt:0];
		[appCounts setObject:tmpSamples forKey:SAMPLE_COUNT_KEY];
	}
	redrawInterval = [userDefaults objectForKey:REDRAW_INTERVAL_PREFS_KEY];
	sampleInterval = [userDefaults objectForKey:SAMPLE_INTERVAL_PREFS_KEY];
	windowTransparency = [userDefaults objectForKey:WINDOW_TRANSPARENCY_PREFS_KEY];
	appIconsCache = [[NSMutableDictionary alloc] init];

	[self setSampleInterval:sampleInterval];
	[self setRedrawInterval:redrawInterval];

	[desktopWindow setFrame:[[NSScreen mainScreen] frame] display:YES];
	[desktopWindow setAlphaValue:[windowTransparency floatValue]];

	[desktopView setNeedsDisplay:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self unbind:@"windowTransparency"];
	[self unbind:@"sampleInterval"];
	[self unbind:@"redrawInterval"];
	[appTimer invalidate]; 
	[appTimer release];
	[redrawTimer invalidate];
	[redrawTimer release];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (userDefaults) {
		[userDefaults setObject:appCounts forKey:APP_COUNT_PREFS_KEY];
		[userDefaults synchronize];
	} else
		NSLog(@"userDefaults was nil, you may have lost some data. Sorry.");
	[appCounts release];
	[appIconsCache release];
}
	
/**
 * @brief called by an NSTimer to tell the app to poll what is frontmost
 */
- (void)checkActiveApp:(NSTimer *)theTimer
{
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString *activeAppName = [activeApp objectForKey:@"NSApplicationName"];
	// app name can be null if it's ScreenSaverEngine or something like that, but sadly Dashboard doesn't count.
	// (Huh? Dashboard != my app. *sigh*)
	if (activeAppName && ![activeAppName isEqualToString:@"WhereDidTheTimeGo"]) { 
		NSNumber *samples;
		unsigned newSamples;
		[self imageForProcessName:activeAppName];
		if ((samples = [appCounts objectForKey:activeAppName]))
			newSamples = [samples intValue] + 1;
		else
			newSamples = 1;
		[appCounts setObject:[NSNumber numberWithUnsignedInt:newSamples] forKey:activeAppName];
		unsigned totalSamples = [[appCounts objectForKey:SAMPLE_COUNT_KEY] intValue]+1;
		[appCounts setObject:[NSNumber numberWithUnsignedInt:totalSamples] forKey:SAMPLE_COUNT_KEY];
		if (!firstDisplay) {
			firstDisplay = YES;
			[desktopView setNeedsDisplay:YES];
		}
	}
}

/**
 * @brief given a process name, return the icon as an NSImage
 *
 * this performs some caching as a feeble workaround on a "bug"
 * in NSWorkspace where for apps that are not in a bundle (MS Word, MS Excel)
 * you can't fetch the icon if the app isn't running. For now,
 * the cache is only kept for a given run of this app, but you
 * could store appIconsCache someplace if you wanted it to persist.
 */
- (NSImage *)imageForProcessName:(NSString *)name
{
	NSImage *appIcon;
	if (!(appIcon = [appIconsCache objectForKey:name])) {
		//really big string...hopefully too big
		char *pathChr=malloc(255*10); 
		UInt32 pathSize=(255*10);
		NSString *appPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:name];
		if (!appPath) { //workaround for evil apps *cough* Excel *cough* Word
			NSArray *appList = [[NSWorkspace sharedWorkspace] launchedApplications];
			NSEnumerator *objEnum = [appList objectEnumerator];
			NSDictionary *tmp;
			while ((tmp = [objEnum nextObject]) && appPath == nil) {
				if ([[tmp objectForKey:@"NSApplicationName"] isEqualToString:name]) {
					if (pathChr != NULL) {
						OSStatus err;
						ProcessSerialNumber psn;
						FSRef fRef;
						err = GetProcessForPID([[tmp objectForKey:@"NSApplicationProcessIdentifier"] intValue],&psn);
						if (!err) err = GetProcessBundleLocation(&psn,&fRef);
						if (!err) err = FSRefMakePath(&fRef, (UInt8 *)pathChr, pathSize);
						if (!err) 
							appPath = [NSString stringWithCString:pathChr];
						else 
							appPath = nil;
						free(pathChr);
					} else 
						appPath = nil;
				}
			}
		}
		appIcon =  appPath ? [[NSWorkspace sharedWorkspace] iconForFile:appPath] : nil;
		if (appIcon)
			[appIconsCache setObject:appIcon forKey:name];
	}
	return appIcon;
}

- (NSDictionary *)getAppStats
{
	return appCounts;
}

- (void)resetAppStats
{
	[appCounts release];
	appCounts = [[NSMutableDictionary alloc] init];
	NSNumber *tmpSamples = [NSNumber numberWithInt:0];
	[appCounts setObject:tmpSamples forKey:SAMPLE_COUNT_KEY];
}


#pragma mark IBActions
//this is lame, we should really redo the draw so that it doesn't get the whole size of
//the screen as blank space...
- (IBAction)savePDF:(id)sender
{
	NSData *pdfData = [desktopView dataWithPDFInsideRect:[desktopView frame]];
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel  runModalForDirectory:NSHomeDirectory() file:DEFAULT_FILE_NAME];
	NSString *target = [savePanel filename];
	[pdfData writeToFile:target atomically:YES];
}

//cheesy copout - help opens an embedded copy of the readme
- (IBAction)showHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:README_FILE_NAME]];
}

- (IBAction)showPrefs:(id)sender
{
	[RAFPreferencesWindowController showPreferences];
}

- (void)redrawWindow:(NSTimer *)theTimer
{
	[desktopView setNeedsDisplay:YES];
	firstDisplay = YES;
}

#pragma mark KVO Get/Set Stuff
- (NSNumber *)maxTrans
{
	return [NSNumber numberWithFloat:1.0];
}
- (NSNumber *)minTrans
{
	return [NSNumber numberWithFloat:0.0];
}

- (NSNumber *)windowTransparency
{
	return [NSNumber numberWithFloat:[desktopWindow alphaValue]];
}
- (void)setWindowTransparency:(NSNumber *)num
{
	[desktopWindow setAlphaValue:[num floatValue]];
}

- (NSNumber *)redrawInterval
{
	return [NSNumber numberWithFloat:[redrawTimer timeInterval]];
}
- (void)setRedrawInterval:(NSNumber *)aNum
{
	[redrawTimer invalidate];
	[redrawTimer release];
	redrawTimer = [NSTimer scheduledTimerWithTimeInterval:[aNum floatValue]
												   target:self
												 selector:@selector(redrawWindow:)
												 userInfo:nil 
												  repeats:YES];
	[redrawTimer retain];
}

- (NSNumber *)sampleInterval
{
	return [NSNumber numberWithFloat:[appTimer timeInterval]];
}
- (void)setSampleInterval:(NSNumber *)aNum
{
	[appTimer invalidate];
	[appTimer release];
	appTimer = [NSTimer scheduledTimerWithTimeInterval:[aNum floatValue]
												   target:self
												 selector:@selector(checkActiveApp:)
												 userInfo:nil 
												  repeats:YES];
	[appTimer retain];
}

@end
