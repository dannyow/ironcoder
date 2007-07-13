//
//  FFMinatorPref.m
//  FFMinator
//
//  Created by Tom Harrington on 3/4/06;10:59 AM.
//  Copyright (c) 2006 Atomic Bird LLC. All rights reserved.
//

#import "FFMinatorPref.h"
#import "FFMinatorGlobal.h"

void moveFileToUserTrash (NSString *filePath) {
	
	NSLog(@"Moving %@ to trash", filePath);

    CFURLRef        trashURL;
    FSRef           trashFolderRef;
    CFStringRef     trashPath;
    OSErr           err;
    NSFileManager   *mgr = [NSFileManager defaultManager];
	
    err = FSFindFolder(kUserDomain, kTrashFolderType, kDontCreateFolder, &trashFolderRef);
    if (err == noErr) {
		trashURL = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &trashFolderRef);
		if (trashURL) {
			trashPath = CFURLCopyFileSystemPath (trashURL, kCFURLPOSIXPathStyle);
			if (![mgr movePath:filePath toPath:[(NSString *)trashPath stringByAppendingPathComponent:[filePath lastPathComponent]] handler:nil])
				NSLog(@"Could not move %@ to trash", filePath);
        }
        if (trashPath) {
            CFRelease(trashPath);
        }
        CFRelease(trashURL);
    }
}

@interface FFMinatorPref (Private)
- (void)restartTool;
- (void)saveToPrefs;
- (void)startStopTool:(BOOL)toolFlag;
@end

@implementation FFMinatorPref

- (void) mainViewDidLoad
{
	[super mainViewDidLoad];
	
	// Load running flag from prefs
	NSNumber *statusValue = (NSNumber *)CFPreferencesCopyValue((CFStringRef)preferencesStatusKey,
															   (CFStringRef)preferencesAppName,
															   kCFPreferencesCurrentUser,
															   kCFPreferencesAnyHost);
	if (statusValue != nil) {
		[startStopStatusButton setState:[statusValue boolValue]];
	} else {
		[startStopStatusButton setState:NSOffState];
	}
	
	// Load "show me your bits" status
	NSNumber *showMeYourBitsValue = (NSNumber *)CFPreferencesCopyValue((CFStringRef)preferencesShowMeYourBitsKey,
															   (CFStringRef)preferencesAppName,
															   kCFPreferencesCurrentUser,
															   kCFPreferencesAnyHost);
	if (showMeYourBitsValue != nil) {
		[showMeYourBitsButton setState:[showMeYourBitsValue boolValue]];
	} else {
		[showMeYourBitsButton setState:NSOffState];
	}

	// Load delay time from prefs
	NSNumber *delayValue = (NSNumber *)CFPreferencesCopyValue((CFStringRef)preferencesDelayKey,
															   (CFStringRef)preferencesAppName,
															   kCFPreferencesCurrentUser,
															   kCFPreferencesAnyHost);
	if (delayValue != nil) {
		[delayValueField setIntValue:[delayValue intValue]];
		[delayValueStepper setIntValue:[delayValue intValue]];
	} else {
		[delayValueField setIntValue:1];
		[delayValueStepper setIntValue:1];
	}
	
	// Make sure the lanuchd plist is set up correctly for wherever we're installed.
	NSString *ffminatorToolPath = [[self bundle] pathForAuxiliaryExecutable:@"FFMinatorTool.app"];
	NSBundle *toolBundle = [NSBundle bundleWithPath:ffminatorToolPath];
	NSString *bundleLaunchdPlistPath = [[self bundle] pathForResource:@"ffminator" ofType:@"plist"];
	NSString *ffminatorToolPathForPlist = [toolBundle executablePath];
	NSMutableDictionary *launchdPlist = [NSMutableDictionary dictionaryWithContentsOfFile:bundleLaunchdPlistPath];
	[[launchdPlist objectForKey:@"ProgramArguments"] replaceObjectAtIndex:0 withObject:ffminatorToolPathForPlist];
	[launchdPlist writeToFile:bundleLaunchdPlistPath atomically:YES];
}

- (void)didUnselect
{
	[self saveToPrefs];
	[self restartTool];
}

- (void)saveToPrefs
{
	CFPreferencesSetValue((CFStringRef)preferencesStatusKey,
						  (CFNumberRef)[NSNumber numberWithBool:[startStopStatusButton state]],
						  (CFStringRef)preferencesAppName,
						  kCFPreferencesCurrentUser,
						  kCFPreferencesAnyHost);
	CFPreferencesSetValue((CFStringRef)preferencesShowMeYourBitsKey,
						  (CFNumberRef)[NSNumber numberWithBool:[showMeYourBitsButton state]],
						  (CFStringRef)preferencesAppName,
						  kCFPreferencesCurrentUser,
						  kCFPreferencesAnyHost);
	//NSLog(@"Saving delay value of %d", [delayValueField intValue]);
	CFPreferencesSetValue((CFStringRef)preferencesDelayKey,
						  (CFNumberRef)[NSNumber numberWithInt:[delayValueField intValue]],
						  (CFStringRef)preferencesAppName,
						  kCFPreferencesCurrentUser,
						  kCFPreferencesAnyHost);
	CFPreferencesSynchronize((CFStringRef)preferencesAppName,
							 kCFPreferencesCurrentUser,
							 kCFPreferencesAnyHost);
}

- (void)restartTool
{
	if ([startStopStatusButton state]) {
		[self startStopTool:NO];
		[self startStopTool:YES];
	}
}

// Get path to the launchd plist's correct location in the user's Library folder
- (NSString *)ffminatorPlistPath
{
	NSArray *userLibraryDirectories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
																		  NSUserDomainMask,
																		  YES);
	NSString *userLibraryDirectory = [userLibraryDirectories objectAtIndex:0];
	NSString *userLaunchDaemonsDirectory = [userLibraryDirectory stringByAppendingString:@"/LaunchAgents/"];
	if ((mkdir([userLaunchDaemonsDirectory fileSystemRepresentation], 0755) != 0) && (errno != EEXIST)) {
		//IFDEBUG(NSLog(@"Failed to create LaunchAgents dir, err=%s", strerror(errno)));
		return nil;
	}
	NSString *ffminatorPlistPath = [userLaunchDaemonsDirectory stringByAppendingString:@"ffminator.plist"];
	return ffminatorPlistPath;
}

// Use launchctl to start or stop the tool
- (void)startStopTool:(BOOL)toolFlag
{
	NSString *action;
	if (toolFlag) {
		action = @"load";
	} else {
		action = @"unload";
	}
	NSArray *arguments = [NSArray arrayWithObjects:action, @"-w", [self ffminatorPlistPath], nil];
	NSString *command = @"/bin/launchctl"; //[NSString stringWithFormat:@"/bin/launchctl %@ -w %@", action, autoNicePlistPath];
	NSTask *startStopTask = [NSTask launchedTaskWithLaunchPath:command
													 arguments:arguments];
#pragma unused(startStopTask)
}

- (IBAction)setStartupStatus:(id)sender
{
	NSLog(@"Setting startup flag");
	// Get path to launchd plist for user, if it exists
	NSString *ffminatorPlistPath = [self ffminatorPlistPath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:ffminatorPlistPath]) {
		// launchd plist needs to be in the right place for launchd to find it.
		NSString *bundleChimeyPlistPath = [[self bundle] pathForResource:@"ffminator" ofType:@"plist"];
		[[NSFileManager defaultManager] copyPath:bundleChimeyPlistPath
										  toPath:ffminatorPlistPath
										 handler:nil];
	}
	if ([sender state] == NSOnState) {
		[self startStopTool:YES];
	} else {
		[self startStopTool:NO];
	}
	[self saveToPrefs];
}

- (IBAction)showHelp:(id)sender
{
	[NSApp beginSheet:helpWindow
	   modalForWindow:[[self mainView] window]
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil
		];
}

- (IBAction)closeHelpWindow:(id)sender
{
	[helpWindow orderOut:sender];
	[NSApp endSheet:helpWindow returnCode:0];
}

- (IBAction)setDelaySeconds:(id)sender
{
	NSLog(@"setting delay");
	int delaySeconds = [sender intValue];
	[delayValueStepper setIntValue:delaySeconds];
	[delayValueField setIntValue:delaySeconds];
	[self saveToPrefs];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:newDelayTimeNotification
																   object:nil
																 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:delaySeconds]
																									  forKey:newDelayTimeKey]];
}

// delegate method from delay text field
- (void)textDidChange:(NSNotification *)aNotification
{
	NSLog(@"text changed");
	[self saveToPrefs];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSLog(@"control text change");
	[self setDelaySeconds:delayValueField];
}

- (IBAction)uninstall:(id)sender
{
	// are you sure?
	int areYouSure = NSRunAlertPanel(@"Removing FFMinator",
									 @"Are you sure you want to uninstall FFMinator?  It's not like there's an 'undo' here.",
									 @"Yes, dammit!",
									 @"Oops, my mistake!",
									 nil);
	
	if (areYouSure != NSAlertDefaultReturn)
		return;
	NSRunAlertPanel(@"Removing FFMinator",
					@"FFMinator and associated files will be moved to the trash",
					@"Get on with it!",
					nil,
					nil,
					nil);
	
	// stop tool, if it's running
	[self startStopTool:NO];

	// remove launchd plist
	NSString *ffminatorPlistPath = [self ffminatorPlistPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:ffminatorPlistPath]) {
		moveFileToUserTrash(ffminatorPlistPath);
	}
	
	// remove prefs
	NSArray *userLibraryDirectories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
																		  NSUserDomainMask,
																		  YES);
	NSString *userLibraryDirectory = [userLibraryDirectories objectAtIndex:0];
	NSString *userPreferencesPath = [userLibraryDirectory stringByAppendingFormat:@"/Preferences/%@.plist", preferencesAppName];
	if ([[NSFileManager defaultManager] fileExistsAtPath:userPreferencesPath]) {
		moveFileToUserTrash(userPreferencesPath);
	}
	
	// remove prefpane
	NSString *prefPanePath = [[self bundle] bundlePath];
	moveFileToUserTrash(prefPanePath);
	
	// quit
	NSRunAlertPanel(@"Removing FFMinator",
					@"FFMinator has been removed.  System Preferences will now exit.",
					@"OK!",
					nil,
					nil,
					nil);
	[[NSApplication sharedApplication] terminate:self];
}

- (IBAction)showMeYourBits:(id)sender
{
	NSNumber *onOffFlag;
	if ([sender state] == NSOnState) {
		onOffFlag = [NSNumber numberWithBool:YES];
	} else {
		onOffFlag = [NSNumber numberWithBool:NO];
	}
	// notify tool
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:newShowMeYourBitsFlagNotification
																   object:nil
																 userInfo:[NSDictionary dictionaryWithObject:onOffFlag
																									  forKey:newShowMeYourBitsFlagKey]];
	
	
	[self saveToPrefs];
}

@end
