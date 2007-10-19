//
//  CrepuscularLife_OptionsController.m
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CrepuscularLife_OptionsController.h"

#import "CrepuscularLife_UserPrefs.h"

@interface CREPLIFE_OptionsController (PrivateMethods)

- (void) alertDidEnd: (NSAlert *) alert returnCode: (int) returnCode  
			contextInfo: (void *) contextInfo;
- (void) updateSheetFromPrefs;
- (void) updateGenerationSpeedField;
- (void) updateGliderFrequencySlider;
- (void) updateGliderFrequencyField;

@end

@implementation CREPLIFE_OptionsController

+ controllerWithUserPrefs: (ScreenSaverDefaults *) initUserPrefs
{
	return [[[self alloc] initWithUserPrefs: initUserPrefs] autorelease];
}

- initWithUserPrefs: (ScreenSaverDefaults *) initUserPrefs
{
	self = [super init];
	
	if (self != nil)
	{
		[NSBundle loadNibNamed: @"CrepuscularLife_Options" owner: self];
		
		if (!optionsSheet || !initUserPrefs)
			goto ERROR;
	
		userPrefs = [initUserPrefs retain];
		
		[self updateSheetFromPrefs];
	}
	
	return self;
	
ERROR:
	[self release];
	
	return nil;
}

- init
{
	return [self initWithUserPrefs: nil];
}

- (void) dealloc
{
	[optionsSheet release];
	[userPrefs release];

	[super dealloc];
}

- (NSWindow*) configureSheet
{
    return optionsSheet;
}

- (void) updateSheetFromPrefs
{
	glidersPerGeneration = [userPrefs integerForKey: kCREPLIFEPrefsKeyGlidersPerGen];
	generationsPerGlider = [userPrefs integerForKey: kCREPLIFEPrefsKeyGensPerGlider];
	gliderFrequencyType = [userPrefs integerForKey: kCREPLIFEPrefsKeyGliderFreqType];
	
	generationSpeed = [userPrefs integerForKey: kCREPLIFEPrefsKeyGenSpeed];

	[gliderFrequencySelector selectItemAtIndex: gliderFrequencyType];
	[self updateGliderFrequencySlider];
	[self updateGliderFrequencyField];
	
	[self updateGenerationSpeedField];
	[generationSpeedSlider setIntValue: generationSpeed];
}

- (IBAction) optionsOKClick: (id) sender
{
	[userPrefs setObject: [NSNumber numberWithInt: generationSpeed] 
										forKey: kCREPLIFEPrefsKeyGenSpeed];

	[userPrefs setObject: [NSNumber numberWithInt: gliderFrequencyType] 
										forKey: kCREPLIFEPrefsKeyGliderFreqType];
										
	[userPrefs setObject: [NSNumber numberWithInt: glidersPerGeneration] 
										forKey: kCREPLIFEPrefsKeyGlidersPerGen];
										
	[userPrefs setObject: [NSNumber numberWithInt: generationsPerGlider] 
										forKey: kCREPLIFEPrefsKeyGensPerGlider];
										
	[userPrefs synchronize];

	[[NSApplication sharedApplication] endSheet: optionsSheet];	
}

- (IBAction) optionsCancelClick: (id) sender
{
	[[NSApplication sharedApplication] endSheet: optionsSheet];

	[self updateSheetFromPrefs];
}

- (IBAction) optionsAboutClick: (id) sender
{
	NSAlert *alertDialog;

	alertDialog = [NSAlert alertWithMessageText: @" " 
								defaultButton: @"OK" 
								alternateButton: nil
								otherButton: nil 
								informativeTextWithFormat: 
@"Crepuscular Life screen saver\nv1.0\n\n\nWritten by Josh Freeman\nTwilight Edge Software\n\ncrepuscular@twilightedge.com\n"];

	[alertDialog beginSheetModalForWindow: optionsSheet 
					modalDelegate: self 
					didEndSelector: @selector(alertDidEnd:returnCode:contextInfo:) 
					contextInfo: nil];

	[[alertDialog window] makeKeyWindow];
					
	[[NSApplication sharedApplication] runModalForWindow: [alertDialog window]];
}

- (void) alertDidEnd: (NSAlert *) alert returnCode: (int) returnCode  
			contextInfo: (void  *) contextInfo
{
	[[NSApplication sharedApplication] endSheet: [alert window]];
	[[alert window] orderOut: self];
}

- (IBAction) moveGenerationSpeedSlider: (id) sender
{
	generationSpeed = [generationSpeedSlider intValue];
	[self updateGenerationSpeedField];
}

- (void) updateGenerationSpeedField
{
	[generationSpeedField setIntValue: generationSpeed];
}

- (IBAction) moveGliderFrequencySlider: (id) sender
{
	if (gliderFrequencyType == gliderFrequencyTypeGlidersPerGeneration)
		glidersPerGeneration = [gliderFrequencySlider intValue];
	else
		generationsPerGlider = [gliderFrequencySlider intValue];

	[self updateGliderFrequencyField];
}

- (void) updateGliderFrequencySlider
{
	if (gliderFrequencyType == gliderFrequencyTypeGlidersPerGeneration)
		[gliderFrequencySlider setIntValue: glidersPerGeneration];
	else
		[gliderFrequencySlider setIntValue: generationsPerGlider];
}


- (void) updateGliderFrequencyField
{
	if (gliderFrequencyType == gliderFrequencyTypeGlidersPerGeneration)
	{
		if (glidersPerGeneration == 1)
		{
			[gliderFrequencyField setStringValue: @"one glider"];
		}
		else
		{
			[gliderFrequencyField setStringValue: 
							[NSString stringWithFormat: @"%d gliders", glidersPerGeneration]];
		}
	}
	else
	{
		if (generationsPerGlider == 1)
		{
			[gliderFrequencyField setStringValue: @"generation"];
		}
		else
		{
			[gliderFrequencyField setStringValue: 
							[NSString stringWithFormat: @"%d generations", generationsPerGlider]];
		}
	
	}
}

- (IBAction) gliderFrequencyTypeSelected: (id) sender
{
	gliderFrequencyType = [gliderFrequencySelector indexOfSelectedItem];
	[self updateGliderFrequencyField];
	[self updateGliderFrequencySlider];
}


@end
