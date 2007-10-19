//
//  OJW_PixureSaverDefaults.h
//  PixureTest
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// With more time, I would probably separate this into a UI and a defaults class, but it seems to work alright as it is

@interface OJW_PixureSaverDefaults : NSObject {
	IBOutlet NSWindow* prefsWindow;
	
	int newPixureType;
}

+ (OJW_PixureSaverDefaults*)OJW_PixureSaverDefaults;
+ (NSUserDefaults*)defaults;


// UI
- (NSWindow*)preferencesWindow;

- (IBAction)doneWithSheet:(id)sender;
- (IBAction)chooseSourceFolder:(id)sender;


// this has to return quickly
- (int)typeOfNewPixure;

@end
