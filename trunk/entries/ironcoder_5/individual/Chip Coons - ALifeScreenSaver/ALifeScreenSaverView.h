//
//  ALifeScreenSaverView.h
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/30/07.
//  Copyright (c) 2007, GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>
#import "alifeMap.h"
#import "alifeGene.h"
#import "alifeEntity.h"


@interface ALifeScreenSaverView : ScreenSaverView 
{
    alifeMap *_currentMap;
    alifeEntity *_currentEntity;
    id _controller;
    
    int runCounter;
}

- (void)updateDisplay;

- (alifeMap*)currentMap;
- (void)setCurrentMap:(alifeMap *)theMap;

- (alifeEntity*)currentEntity;
- (void)setCurrentEntity:(alifeEntity *)theEntity;

- (void)skipEntity;

- (id)controller;
- (void)setController:(id)aController;

- (void)resetCounter;
- (int)count;

- (BOOL)entityWillMove;

@end
