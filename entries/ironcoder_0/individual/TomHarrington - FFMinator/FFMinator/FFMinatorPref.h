//
//  FFMinatorPref.h
//  FFMinator
//
//  Created by Tom Harrington on 3/4/06;10:59 AM.
//  Copyright (c) 2006 Atomic Bird LLC. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface FFMinatorPref : NSPreferencePane 
{
	IBOutlet NSButton *startStopStatusButton;
	IBOutlet NSTextField *delayValueField;
	IBOutlet NSStepper *delayValueStepper;
	IBOutlet NSWindow *helpWindow;
	IBOutlet NSButton *showMeYourBitsButton;
}

- (void) mainViewDidLoad;

- (IBAction)setStartupStatus:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)closeHelpWindow:(id)sender;
- (IBAction)setDelaySeconds:(id)sender;
- (IBAction)uninstall:(id)sender;
- (IBAction)showMeYourBits:(id)sender;
@end
