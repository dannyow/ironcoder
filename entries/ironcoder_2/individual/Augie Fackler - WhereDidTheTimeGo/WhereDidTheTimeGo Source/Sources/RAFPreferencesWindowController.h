//
//  RAFPreferencesWindowController.h
//  WhereDidTheTimeGo
//
//  Created by Augie Fackler on 7/23/06.
//  Copyright 2006 R. August Fackler. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RAFPreferencesWindowController : NSWindowController {
}

+ (RAFPreferencesWindowController *)showPreferences;

- (IBAction)resetPrefs:(id)sender;
- (IBAction)resetStats:(id)sender;

@end
