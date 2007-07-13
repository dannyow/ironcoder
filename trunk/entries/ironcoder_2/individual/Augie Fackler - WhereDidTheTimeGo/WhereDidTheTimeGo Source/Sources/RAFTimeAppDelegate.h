//
//  RAFTimeAppDelegate.h
//  WhereDidTheTimeGo
//
//  Created by Augie Fackler on 7/22/06.
//  Copyright 2006 R. August Fackler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define APP_COUNT_PREFS_KEY @"AppCounts"
#define REDRAW_INTERVAL_PREFS_KEY @"RedrawInterval"
#define SAMPLE_INTERVAL_PREFS_KEY @"SampleInterval"
#define WINDOW_TRANSPARENCY_PREFS_KEY @"WindowTransparency"
#define SAMPLE_COUNT_KEY @"WhereDidTheTimeGo:SampleCount"
#define README_FILE_NAME @"Read Me.rtfd"
#define DEFAULT_FILE_NAME @"My Time.pdf"

@interface RAFTimeAppDelegate : NSObject {
	NSTimer				*appTimer;
	NSTimer				*redrawTimer;
	IBOutlet NSWindow	*desktopWindow;
	IBOutlet NSView		*desktopView;
	
	NSMutableDictionary *appCounts;
	// getting app icons is a pain and potentially slow, so cache them
	// also, if an app like, say, Excel, quits, we can't get its icon anymore
	// this fixes that for at least the current session
	NSMutableDictionary *appIconsCache;
}

+ (void)setupDefaults;
- (void)checkActiveApp:(NSTimer *)theTimer;
- (NSImage *)imageForProcessName:(NSString *)name;
- (NSDictionary *)getAppStats;
- (void)resetAppStats;

- (void)redrawWindow:(NSTimer *)theTimer;

- (IBAction)savePDF:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)showPrefs:(id)sender;

- (NSNumber *)maxTrans;
- (NSNumber *)minTrans;
- (NSNumber *)windowTransparency;
- (void)setWindowTransparency:(NSNumber *)num;
- (NSNumber *)redrawInterval;
- (void)setRedrawInterval:(NSNumber *)aNum;
- (NSNumber *)sampleInterval;
- (void)setSampleInterval:(NSNumber *)aNum;

@end
