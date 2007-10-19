//
//  alifeEntity.h
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/30/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "alifeGene.h"
#import "alifeMap.h"

/*
From : http://www.cs.bgu.ac.il/~sipper/courses/ecal051/e3.html
Ant functions and terminals. The functions and terminals are executed to move the ant on the grid 
    during evaluation:

        0 : if_food_ahead(a,b) : if the ant faces a food pellet then evaluate a, else evaluate b
        1 : progn2(a,b) : evaluate a, then b, returning b's value
        2 : progn3(a,b,c) : evaluate a, b then c, returning c's value
        3 : left : turn the ant left by 90 degrees
        4 : right : turn the ant right by 90 degrees
        5 : move : move the ant forward by one square/step
        Genes represent the state machine used to determine behavior.
        Think of it as a list of numbers.  Each number represents either a function or a term action
        in the grammar.  Current state is the current point of evaluation in the list.

*/



@interface alifeEntity : NSObject {

    alifeGene *genes;
    alifeGene *currentEvaluationPoint;
    int x, y;
    unsigned int generation;
    unsigned int age;
    int heading;
    unsigned int food;
    int evalIndex;
    NSMutableArray *stackArray;
    int _ifResult;
}

- (id)initWithRandomGenes;

- (alifeGene *)genes;
- (void)setGenes:(alifeGene*)value;
- (alifeGene *)currentGeneticMarker;
- (NSPoint)currentLocation;
- (NSPoint)nextLocation;
- (unsigned int)generation;
- (void)setGeneration:(unsigned int)value;
- (int)currentHeading;
- (unsigned int)currentAge;
- (unsigned int)currentDepth;
- (void)reset:(unsigned int)newGeneration;

- (void)turnLeft;
- (void)turnRight;
- (void)move;
- (BOOL)foodAhead:(alifeMap*)map;
- (void)executeStepOnMap:(alifeMap*)aMap;
- (void)walk:(alifeMap*)aMap;
- (alifeGene *)nextAction:(alifeMap*)aMap;
- (void)takeTerminalAction;

- (void)push:(id)value;
- (id)pop;
- (id)top;
- (void)flush;

- (unsigned int)fitness;
- (void)setFitness:(unsigned int)value;

// allow two entities to breed
- (NSString*)spliceGene:(NSString*)fullGene;
- (alifeEntity *)breedWith:(alifeEntity*)partner;

- (NSComparisonResult)compareFitness:(alifeEntity *)aValue;

@end
