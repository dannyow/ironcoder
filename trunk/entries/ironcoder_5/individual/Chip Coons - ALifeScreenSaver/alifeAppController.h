//
//  alifeAppController.h
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/31/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ALifeScreenSaverView.h"
#import "alifeEntity.h"
#import "alifeGene.h"
#import "alifeMap.h"

#define maxGenerations 10000

extern NSString * const kEntityName;
extern NSString * const kEntityFitness;


@interface alifeAppController : NSObject {
	IBOutlet NSView *screenView;
    IBOutlet NSButton *seedButton;
	IBOutlet NSButton *controlButton;
    IBOutlet NSButton *skipButton;
    IBOutlet NSButton *breedButton;
    
	NSMutableDictionary *displayData;
	
    alifeMap *theMap;
    ALifeScreenSaverView *myDisplay;
    NSMutableArray *totalPopulation;
    float runs;
    float fit;
    
	
}

- (void)buildPopulation;
- (int)runDuration;
- (void)setRemainingRuntime:(int)value;

- (int)currentGeneration;
- (int)currentEntityIndex;
- (alifeEntity *)nextEntity;
- (void)updateEntity:(alifeEntity*)anEntity;

- (IBAction)startButton:(id)sender;
- (IBAction)skipEntity:(id)sender;
- (IBAction)seedPopulation:(id)sender;
- (IBAction)forceBreeding:(id)sender;

- (void)sortPopulation;
- (void)genocide;
- (void)repopulate;
- (void)resetPopulation;
@end
