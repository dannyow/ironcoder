//
//  OJW_PixureSaverDefaults.m
//  PixureTest
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "OJW_PixureSaverDefaults.h"
#import <ScreenSaver/ScreenSaver.h>

@implementation OJW_PixureSaverDefaults

// Any Class-Specific code goes here


- (NSUserDefaults*)defaults;
{
	return [ScreenSaverDefaults defaultsForModuleWithName:@"com.oldjewel.pixuresaver"];

//[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.oldjewel.pixuresaver"]
 }


+ (NSUserDefaults*)defaults;
{
	return [[OJW_PixureSaverDefaults OJW_PixureSaverDefaults] defaults];
}


- (NSWindow*)preferencesWindow;
{
	[[self defaults] synchronize];

	if (nil == prefsWindow)
	{
	     NSDictionary* table = [NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", nil];
		//[NSBundle loadNibNamed:@"Pixure Preferences" owner:self];
		[[NSBundle bundleForClass:[self class]] loadNibFile:@"Pixure Preferences" externalNameTable:table withZone:[self zone]];
	}

	[[self defaults] synchronize];

	return prefsWindow;
}


#pragma mark -
#pragma mark Convenience Accessors

- (NSString*)userPictureFolderName;
{
	return [[[self defaults] stringForKey:@"userPictureFolderPath"] lastPathComponent];
}

- (int)typeOfNewPixure;
{
	return newPixureType;
}

#pragma mark -
#pragma mark Preferences Window Actions

- (IBAction)doneWithSheet:(id)sender;
{
	//NSBeep();
	[NSApp endSheet:[self preferencesWindow]];
	[[self preferencesWindow] orderOut:self];
	
	[[OJW_PixureSaverDefaults defaults] synchronize];
	
	newPixureType = [[OJW_PixureSaverDefaults defaults] integerForKey:@"startingPixureType"];
}

- (IBAction)chooseSourceFolder:(id)sender;
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setPrompt:@"Choose"];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setDelegate:self];
	
	[openPanel beginSheetForDirectory:[@"~/Pictures/" stringByStandardizingPath] file:@""
		types:nil
		modalForWindow:[sender window] modalDelegate:self
		didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
		contextInfo:NULL];
}


- (void)openPanelDidEnd:(NSOpenPanel *)openPanel
		returnCode:(int)returnCode
			contextInfo:(void *)contextInfo
{
	if (returnCode != NSOKButton) 
		return;
	
	NSString* filePath = [openPanel filename];
	
	[self willChangeValueForKey:@"userPictureFolderName"];
	[[self defaults] setObject:filePath forKey:@"userSelectedFolder"];
	[[self defaults] synchronize];
	[self didChangeValueForKey:@"userPictureFolderName"];
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
	BOOL isDir;
	return [[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir] && isDir;
}

#pragma mark -
#pragma mark May want to change
- (void)finishInit;
{
	// do all the specific init here so it's called at the right time
	newPixureType = [[OJW_PixureSaverDefaults defaults] integerForKey:@"startingPixureType"];
}

- (void)finishDealloc;
{
	// do all the specific dealloc here so it's called at the right time
}

- (void)finishAppQuit;
{
	// do all the specific app termination code here so it's called at the right time
}








#pragma mark -
#pragma mark Initialization

- (id) init {

    static OJW_PixureSaverDefaults *sharedInstance = nil;

    if (sharedInstance) {
        [self autorelease];
        self = [sharedInstance retain];
    } else {
        self = [super init];
        if (self) 
		{
            sharedInstance = [self retain];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillQuit:) name:NSApplicationWillTerminateNotification object:NSApp];
			[self finishInit];
		}
    }

    return self;
}

- (void)dealloc
{
	[self finishDealloc];
	[super dealloc];
}

+ (OJW_PixureSaverDefaults*)OJW_PixureSaverDefaults;
{
	static OJW_PixureSaverDefaults * sharedInstance = nil;

	if ( sharedInstance == nil )
	        sharedInstance = [[self alloc] init];

	return sharedInstance;
}

- (void)appWillQuit:(NSNotification*)unused
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self finishAppQuit];
}



@end