//
//  CrepuscularLife_OptionsController.h
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface CREPLIFE_OptionsController : NSObject 
{
	ScreenSaverDefaults *userPrefs;
	
	IBOutlet NSPanel *optionsSheet;
	IBOutlet NSSlider *generationSpeedSlider;
	IBOutlet NSTextField *generationSpeedField;
	IBOutlet NSSlider *gliderFrequencySlider;
	IBOutlet NSTextField *gliderFrequencyField;
	IBOutlet NSPopUpButton *gliderFrequencySelector;
	
	int glidersPerGeneration;
	int generationsPerGlider;
	int gliderFrequencyType;
	int generationSpeed;
}

+ controllerWithUserPrefs: (ScreenSaverDefaults *) initUserPrefs;
- initWithUserPrefs: (ScreenSaverDefaults *) initUserPrefs;

- (NSWindow*) configureSheet;

- (IBAction) optionsOKClick: (id) sender;
- (IBAction) optionsCancelClick: (id) sender;
- (IBAction) optionsAboutClick: (id) sender;
- (IBAction) moveGenerationSpeedSlider: (id) sender;
- (IBAction) moveGliderFrequencySlider: (id) sender;
- (IBAction) gliderFrequencyTypeSelected: (id) sender;

@end
