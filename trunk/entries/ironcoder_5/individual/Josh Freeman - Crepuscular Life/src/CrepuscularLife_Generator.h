//
//  CrepuscularLife_Generator.h
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CrepuscularLife_View.h"

@interface CREPLIFE_View (LifeGenerator)

- (bool) initializeFirstGeneration;
- (void) nextGeneration;

@end
